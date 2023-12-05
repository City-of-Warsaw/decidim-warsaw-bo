# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user generate ranking lists
    class GenerateRankingLists < Rectify::Command

      # Public: Initializes the command.
      # current_component - projects component
      # current_user - The current user.
      def initialize(current_user, projects_component)
        @projects_component = projects_component # process component
        @edition = projects_component.process # current_process / edition
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      #
      # Returns nothing.
      def call
        return broadcast(:conflicts_remaining) if any_conflicts_remaining?

        transaction do
          clear_ranking_data

          create_or_update_projects_ranks

          verify_votes_number_threshold
          update_positions_on_ranking_lists
          create_log(projects.first,:generate_ranking_list)
        end

        broadcast(:ok)
      end

      private

      def create_log(resource, log_type)
        Decidim.traceability.perform_action!(
          log_type,
          resource,
          current_user,
          visibility: 'admin-only'
        )
      end

      def clear_ranking_data
        project_ranks.update_all(drawing_projects_log_id: nil, status: nil)

        Decidim::Projects::DrawingProjectsLog.delete_all
      end

      # Check if all projects with conflicts was resolved
      def any_conflicts_remaining?
        Decidim::Projects::ProjectsFromEdition.for(@projects_component).conflict_status_waiting.any?
      end

      # Select projects for each district ranking list
      def update_positions_on_ranking_lists
        # first district projects and then general municipal because they have priority for the same location
        Decidim::Scope.where.not(code: 'om').each do |scope|
          update_positions_on_ranking_list(scope)
        end
        update_positions_on_ranking_list(Decidim::Scope.citywide)
      end

      # verify if any of project's conflicts is on ranking list already
      def any_conflicted_project_on_list?(project)
        return false unless project.conflict_status_with_conflicts?

        Decidim::Projects::ProjectsFromEdition.for(@projects_component)
                                              .on_ranking_list
                                              .where(id: project.projects_in_conflict.pluck(:id))
                                              .any?
      end

      # Private method that iterates through collection of ProjectRank's withing given scope and determines
      # if object should be on the rank list or not based on it's budget value
      def update_positions_on_ranking_list(scope)
        ranks_collection = project_ranks.within_minimum_votes_limit.for_scope(scope).sorted_by_valid_votes_count
        max_budget_value = @edition.budget_value_for(scope)
        return if max_budget_value.nil?

        current_total = 0.00
        ranks_collection.group(:valid_votes_count).count.each do |valid_votes_count, projects_number|
          # => { 2=>1, 1=>4, 0=>1 }
          next if valid_votes_count.zero? # omit projects that did not get votes

          # ranking objects with the same number of votes
          ranks = ranks_collection.where(valid_votes_count: valid_votes_count)
          # take only those without conflicts with others already on the list
          ranks.each do |pr|
            pr.update_column('status', 'excluded_by_conflict') if any_conflicted_project_on_list?(pr.project)
          end
          ranks = ranks.select{ |pr| pr unless any_conflicted_project_on_list?(pr.project) }
          # remove those that do not fit into the budget
          ranks = ranks.select{ |pr| pr if (current_total + pr.project.budget_value <= max_budget_value) }
          next if ranks.size.zero?

          if ranks.size == 1
            pr = ranks.first
            # add to the list
            current_total += pr.project.budget_value
            pr.update_column('status', 'on_the_list')
          else
            # draw the order
            # then add them one by one to the list as long as they are within the budget and have no conflicts
            drawing_projects_log = Decidim::Projects::DrawingProjectsLog.new
            drawing_projects_log.scope = scope
            drawing_projects_log.all_project_ids = ranks.map{ |r| r.project_id }
            shuffled_ranks = ranks.shuffle
            shuffled_ranks.each do |pr|
              if any_conflicted_project_on_list?(pr.project)
                pr.update_column('status', 'excluded_by_conflict')
                next
              end

              if current_total + pr.project.budget_value <= max_budget_value
                current_total += pr.project.budget_value
                pr.update_column('status', 'on_the_list')
                drawing_projects_log.winning_project_ids << pr.project_id
              else
                # skip projects that do not fit in the budget
              end
            end
            drawing_projects_log.save
            # we update the draw information in project_ranks
            shuffled_ranks.each{ |r| r.update_column('drawing_projects_log_id', drawing_projects_log.id) }
          end
        end
      end

      # Public method that iterates over the collection to stet the value of the votes_limit_reached boolean field
      # based on the fact if associated project gathered minimum votes needed
      # to be put on the ranking list
      #
      # Returns nothing
      def verify_votes_number_threshold
        project_ranks.each do |rank|
          rank.update_column('votes_limit_reached', votes_limit_reached?(rank))
        end
      end

      # Private method checking if votes count is equal or higher than minimum of needed votes
      #
      # Returns Boolean
      def votes_limit_reached?(rank)
        rank.valid_votes_count >= minimum_votes_for_project(rank.project)
      end

      # Private method fetching the minimum project votes number for process
      #
      # Returns Integer
      def minimum_votes_for_project(project)
        project.is_global_project? ? @edition.minimum_global_scope_projects_votes : @edition.minimum_district_scope_projects_votes
      end

      # create or update rank for each project in edition
      def create_or_update_projects_ranks
        projects.each do |project|
          if project.project_rank
            update_project_rank(project)
          else
            generate_project_rank(project)
          end

          update_projects_vote_counters(project)
        end
      end

      # Private method that creates ProjectRank for given project
      def generate_project_rank(project)
        Decidim::Projects::ProjectRank.create(project_rank_attributes(project))
      end

      def update_project_rank(project)
        project.project_rank.update(project_rank_attributes(project))
      end

      def update_projects_vote_counters(project)
        project.update_columns(
          votes_count: project.vote_cards.valid.count,
          votes_percentage: percentage_of_verified_scope_votes(project)
        )
      end

      # returns Float
      def percentage_of_not_verified_votes(project)
        return 0.00 if project.vote_cards.submitted.none?

        project.vote_cards.not_verified.count.to_f / project.vote_cards.submitted.count.to_f * 100
      end

      def percentage_of_verified_scope_votes(project)
        return 0.00 if project.vote_cards.valid.none?

        if project.scope.citywide?
          project.vote_cards.valid.count.to_f / Decidim::Projects::VoteCard.valid.where(component: project.component).count.to_f * 100
        else
          project.vote_cards.valid.count.to_f / Decidim::Projects::VoteCard.valid.where(
                                                                                    component: project.component,
                                                                                    scope: project.scope).count.to_f * 100
                                                                                  )
        end
      end

      def project_rank_attributes(project)
        {
          project_id: project.id,
          scope_id: project.decidim_scope_id,
          votes_count: project.vote_cards.count,
          valid_votes_count: project.vote_cards.valid.count,
          not_verified_votes_count: project.vote_cards.not_verified.count,
          invalid_votes_count: project.vote_cards.invalid.count,
          votes_in_paper_count: project.vote_cards.in_paper.count,
          votes_electronic_count: project.vote_cards.electronic.count,
          percentage_of_not_verified_votes: percentage_of_not_verified_votes(project),
          percentage_of_scope_votes: percentage_of_verified_scope_votes(project)
        }
      end

      # all projects selected for voting process from current edition only
      def projects
        @projects ||= Decidim::Projects::ProjectsForVoting.for(@projects_component)
      end

      # project_ranks from current edition only
      def project_ranks
        @project_ranks ||= Decidim::Projects::ProjectRank
                             .where(project_id: Decidim::Projects::ProjectsFromEdition.for(@projects_component).pluck(:id))
      end
    end
  end
end
