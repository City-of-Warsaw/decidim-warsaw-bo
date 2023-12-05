# frozen_string_literal: true

module Decidim
  module Projects
    # This job is used to send mails to remind coordinators about not finished projects evaluations in current edition
    class RemindAboutMissingEvaluationsProjectsJob < ApplicationJob
      include Decidim::EmailChecker

      queue_as :events

      def perform
        projects_component_id = Current.actual_edition.projects_component&.id
        Decidim::AdminExtended::Department.all.each do |department|
          # Nie ma oceny lub niezaakceptowana
          projects_in_evaluation = department.projects
                                             .where(decidim_component_id: projects_component_id)
                                             .in_evaluation
                                             .where.not(verification_status: Decidim::Projects::Project::VERIFICATION_STATES::FINISHED)
          next if projects_in_evaluation.none?

          department.coordinators.each do |coordinator|
            next if coordinator.email.blank?
            next unless valid_email?(coordinator.email)

            ProjectMailer.remind_about_missing_evaluations(coordinator, projects_in_evaluation).deliver_later
          end
        end
      end
    end
  end
end
