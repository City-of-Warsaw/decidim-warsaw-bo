# frozen_string_literal: true

module Decidim
  module AdminExtended
    class GetStatisticsData < Rectify::Command
      # Public: Initializes the command.

      def initialize(form)
        self.scope_type = form.scope_type
        self.edition_year = form.edition_year
        self.scope_id = form.scope_id
        self.scope_collection = form.scope_collection
      end

      def call
        calculate_stats
      end

      private

      def calculate_stats
        return [] if participatory_process.nil?

        participatory_process.map { |item| format_data(item, scope_collection) }
      end

      def format_data(participatory_process, scope_ids)
        {
          edition_year: participatory_process.edition_year,
          budget: get_budget(participatory_process, scope_ids),
          number_of_authors: get_number_of_authors(participatory_process),
          average_number_project_person: get_average_number_project_person(participatory_process),
          number_of_projects_papers: get_number_of_projects(participatory_process, 'paper'),
          number_of_projects_electronic: get_number_of_projects(participatory_process, 'electronic'),
          number_of_projects_approved: get_number_of_projects_approved(participatory_process),
          number_of_projects_withdrawn_by_authors: get_number_of_projects_withdrawn_by_authors(participatory_process),
          number_of_projects_rejected: get_number_of_projects_rejected(participatory_process),
          number_of_voters_0_18: number_of_project_voters_0_18(participatory_process),
          number_of_voters_19_24: number_of_project_voters_19_24(participatory_process),
          number_of_voters_25_34: number_of_project_voters_25_34(participatory_process),
          number_of_voters_35_44: number_of_project_voters_35_44(participatory_process),
          number_of_voters_45_64: number_of_project_voters_45_64(participatory_process),
          number_of_voters_65_100: number_of_project_voters_65_100(participatory_process)
        }
      end

      def get_budget(participatory_process, scope_id)
        participatory_process.scope_budgets.where(decidim_scope_id: scope_id).sum(:budget_value).to_i
      end

      def get_number_of_projects(participatory_process, type)
        if type == 'paper'
          projects(participatory_process).where(is_paper: true).count
        else
          projects(participatory_process).where(is_paper: false).count
        end
      end

      def get_number_of_projects_approved(participatory_process)
          projects(participatory_process).where(state: [Decidim::Projects::Project::POSSIBLE_STATES::ACCEPTED,
                                                        Decidim::Projects::Project::POSSIBLE_STATES::SELECTED,
                                                        Decidim::Projects::Project::POSSIBLE_STATES::NOT_SELECTED])
                                         .count
      end

      def get_number_of_projects_withdrawn_by_authors(participatory_process)
        projects(participatory_process).where(state: Decidim::Projects::Project::POSSIBLE_STATES::WITHDRAWN).count
      end

      def get_number_of_projects_rejected(participatory_process)
        projects(participatory_process).where(state: Decidim::Projects::Project::POSSIBLE_STATES::REJECTED).count
      end

      def get_number_of_authors(participatory_process)
        projects(participatory_process).joins(:coauthorships).where("decidim_coauthorships.decidim_author_type": 'Decidim::UserBaseEntity',
                                                                    "decidim_coauthorships.coauthorable_type": 'Decidim::Projects::Project',
                                                                    "decidim_coauthorships.coauthor": false).group('decidim_coauthorships.decidim_author_id').count.keys.count
      end

      def get_average_number_project_person(participatory_process)
        return 0 if projects(participatory_process).count.zero? || get_number_of_authors(participatory_process).zero?

        (projects(participatory_process).count.to_f / get_number_of_authors(participatory_process)).round
      end

      def number_of_project_voters_0_18(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_0_18.to_i
        end
        sum_statistics.to_i
      end

      def number_of_project_voters_19_24(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_19_24.to_i
        end
        sum_statistics.to_i
      end

      def number_of_project_voters_25_34(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_25_34.to_i
        end
        sum_statistics.to_i
      end

      def number_of_project_voters_35_44(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_35_44.to_i
        end
        sum_statistics.to_i
      end

      def number_of_project_voters_45_64(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_45_64.to_i
        end
        sum_statistics.to_i
      end

      def number_of_project_voters_65_100(participatory_process)
        sum_statistics = 0
        scope_collection.each do |scope|
          sum_statistics += get_statistics_for_participatory_process(participatory_process, scope)&.number_of_project_voters_65_100.to_i
        end
        sum_statistics.to_i
      end

      def participatory_process
        Decidim::ParticipatoryProcess.published.where(edition_year: edition_year).order(edition_year: :desc)
      end

      def get_statistics_for_participatory_process(participatory_process, scope)
        Decidim::Projects::StatisticsParticipatoryProcess
          .find_by(scope_id: scope, participatory_process: participatory_process)
      end

      def projects(participatory_process)
        Decidim::Projects::Project.where(component: participatory_process.projects_component, decidim_scope_id: scope_collection).except_drafts.not_hidden
      end

      attr_accessor :scope_type, :edition_year, :scope_id, :scope_collection
    end
  end
end
