# frozen_string_literal: true

module Decidim
  module Projects
    module Admin::Evaluation
      # A command with all the business logic when a user assigns or reassigns project to sub_coordinator.
      class ForwardToUser < Rectify::Command

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(project, current_user, user)
          @project = project
          @user = user
          @current_user = current_user
          @action = @user ? 'forward_to_user' : 'remove_sub_coorinator'
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          transaction do
            submit_project_to_user
            send_notification if user
          end
          broadcast(:ok, project)
        end

        # private

        attr_reader :project, :action, :current_user, :user

        def submit_project_to_user
          @project = Decidim.traceability.perform_action!(
            action,
            project,
            current_user,
            visibility: "admin-only"
          ) do
            project.update(current_sub_coordinator: user) # can be nil
            project.users << user if user
            project
          end
        end

        def send_notification
          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'project_assigned_for_management_email_template')
          return unless mail_template&.filled_in?

          Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
        end
      end
    end
  end
end
