# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to accept evaluations in many projects at once.
      class AcceptEvaluations < Rectify::Command
        # Public: Initializes the command.
        #
        # component - The component that contains the projects.
        # user      - the Decidim::User that is accepting changes.
        # project_ids - the identifiers of the projects with the evaluations to be accepted.
        def initialize(component, user, project_ids)
          @component = component
          @user = user
          @project_ids = project_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are no projects.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid, []) unless projects.any?

          # accepted_ids = []
          projects.each do |project|
            transaction do
              accept_evaluation(project)
              # r = accept_evaluation(project)
              # accepted_ids << project.id if r == :ok
            end
          end

          # broadcast(:ok, accepted_ids)
          broadcast(:ok)
        end

        private

        attr_reader :component, :user, :project_ids

        # Private: fetch projects
        #
        # returns collection with evaluation that needs acceptance
        def projects
          @projects ||= Decidim::Projects::Project
                         .published
                         .awaits_evaluation_acceptance
                         .where(component: component)
                         .where(id: project_ids)
        end

        # Private: accepting evaluation of single project
        #
        # Method calls command for accepting evaluation based on a current
        # verification status
        #
        # returns nothing
        def accept_evaluation(project)
          case project.verification_status
          when 'formal_finished'
            Decidim::Projects::Admin::Evaluation::AcceptFormal.call(project, user)
          when 'meritorical_finished'
            Decidim::Projects::Admin::Evaluation::AcceptMeritorical.call(project, user)
          when 'appeal_verification_finished'
            Decidim::Projects::Admin::Reevaluation::SubmitToOrganizationAdmin.call(project.appeal, user)
          when 'appeal_admin_verification'
            Decidim::Projects::Admin::Reevaluation::FinishReevaluation.call(project.appeal, user)
          end
        end
      end
    end
  end
end
