# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command for sending projects draft information to authors
      class RemindDraft < Rectify::Command

        # Public: Initializes the command.
        #
        # no params
        def initialize
        end

        # Executes the command.
        # Returns nothing.
        # https://bo-rdm.um.warszawa.pl/issues/735
        # https://bo-rdm.um.warszawa.pl/issues/383?issue_count=42&issue_position=42&prev_issue_id=498
        def call
          actual_edition = Decidim::ParticipatoryProcess.actual_edition
          if actual_edition.active_step && actual_edition.active_step.system_name == "submitting"
            if actual_edition.active_step.end_date + 2 == Date.today
              Decidim::Projects::Project.where(edition_year: actual_edition.edition_year).all.each do |project|
                user = project.authors.first
                next if user.eamil.blank?

                Decidim::Projects::EvaluationMailer.notify(project, "draft_reminder", nil, user).deliver_later
              end

              # OR - Przemek do sprawdzenia:
              # users = Decidim::Projects::Project.where(edition_year: actual_edition.edition_year).all.map { |proj| proj.authors.first }
              # mapowanie dodano ze wzgledu na nieobslugiwanie Active::Recorda i Active::Relations etc.
              # https://api.rubyonrails.org/classes/ActiveJob/SerializationError.html
              # Decidim::Projects::EvaluationJob.perform_later(project, "draft_reminder", nil, actual_edition)
            end
          end
        end

        private

        attr_reader :form, :project
        
      end
    end
  end
end
