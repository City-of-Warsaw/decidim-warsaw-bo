# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to assign evaluator to many projects at once.
      class AssignEvaluatorToProjects < Rectify::Command
        # Public: Initializes the command.
        #
        # component    - The component that contains the projects.
        # user         - the Decidim::User that is accepting changes.
        # project_ids  - the identifiers of the projects with the changes to be accepted.
        # evaluator_id - params[:valuator]
        def initialize(component, user, project_ids, valuator)
          @component = component
          @user = user
          @project_ids = project_ids
          @evaluator = Decidim::User.find_by(id: valuator[:id]) if valuator
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are no projects.
        #
        # Method iterates through projects collection
        # and skips projects if there is a mismatch between
        # @evaluator.department && project.current_department
        #
        # Returns nothing.
        def call
          assigned_info = []
          return broadcast(:invalid) unless @evaluator # can not unassign
          return broadcast(:invalid) unless projects.any?

          projects.each do |project|
            # skipping for department mismatch
            assigned_info << { not_assigned: project.esog_number } if @evaluator && project.current_department != @evaluator.department

            assigned_info << reassign_evaluator(project)
          end

          broadcast(:ok, prepared_response(assigned_info))
        end

        private

        attr_reader :component, :user, :project_ids

        # Private: fetch projects
        #
        # returns collection of published projects
        def projects
          @projects ||= Decidim::Projects::Project
                          .published
                          .where(component: component)
                          .where(id: project_ids)
        end

        # Private: assigning evaluators to single project
        #
        # Method calls command that submits for evaluation
        # based on a current verification status or
        # reassigns if there is evaluator
        #
        # returns nothing
        def reassign_evaluator(project)
          case project.verification_status
          when Decidim::Projects::Project::VERIFICATION_STATES::WAITING
            # for first verificator - formal verification
            Decidim::Projects::Admin::Evaluation::SubmitForFormal.call(project, user, @evaluator)
          when Decidim::Projects::Project::VERIFICATION_STATES::FORMAL
            # changing verificator
            Decidim::Projects::Admin::Evaluation::ChangeVerificator.call(project, user, @evaluator) do
              on(:ok) do
                return { assigned: project.esog_number }
              end
              on(:invalid) do
                return { not_assigned: project.esog_number }
              end
            end
          when Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED
            # for first verificator - meritorical verification
            Decidim::Projects::Admin::Evaluation::SubmitForMeritorical.call(project, user, @evaluator) do
              on(:ok) do
                changed << project.esog_number
              end
              on(:invalid) do
                return { not_assigned: project.esog_number }

              end
            end
          when Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL
            # changing verificator
            Decidim::Projects::Admin::Evaluation::ChangeVerificator.call(project, user, @evaluator) do
              on(:ok) do
                return { assigned: project.esog_number }

              end
              on(:invalid) do
                return { not_assigned: project.esog_number }

              end
            end
          when Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING
            # for assigning
            Decidim::Projects::Admin::Reevaluation::SubmitForVerification.call(project.appeal, user, @evaluator) do
              on(:ok) do
                return { assigned: project.esog_number }
              end
              on(:invalid) do
                return { not_assigned: project.esog_number }
              end
            end
          else
            # any change as long as there is an evaluator
            Decidim::Projects::Admin::Evaluation::ChangeVerificator.call(project, user, @evaluator) do
              on(:ok) do
                return { assigned: project.esog_number }
              end
              on(:invalid) do
                return { not_assigned: project.esog_number }
              end
            end
          end
        end

        def prepared_response(sum)
          sum.flat_map(&:entries)
             .group_by(&:first)
             .map { |k, v| Hash[k, v.map(&:last)] }.inject(:merge)
        end
      end
    end
  end
end
