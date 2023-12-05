# frozen_string_literal: true

module Decidim
  module Projects
  module Admin
    # A command with all the business logic when a user accepts coauthorship od the project.
    class AcceptCoauthorship < Rectify::Command
      # Public: Initializes the command.
      #
      # coauthorship     - The coauthorsip to accept
      # user     - The current user.
      def initialize(coauthorship, current_user)
        @coauthorship = coauthorship
        @project = coauthorship&.coauthorable
        @user = coauthorship&.author
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the project.
      # - :invalid if data is invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid)  if @coauthorship.nil?
        transaction do
          accept_coauthorship
          send_notification
        end

        broadcast(:ok, @project)
      end

      private

      # private method
      #
      # updating Coauthorship status to 'confirmed' and acceptance data to Date.current
      # and creating ActionLog of the event
      #
      # returns Object - Decidim::Coauthorship
      def accept_coauthorship
        Decidim.traceability.perform_action!(
          "accept_coauthorship",
          @project,
          @current_user,
          visibility: "admin-only"
        )
        @coauthorship.confirm
      end

      def send_notification
        mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthorship_confirmation_admin')
        if mail_template&.filled_in?
          Decidim::Projects::TemplatedMailerJob.perform_later(@project, @user, mail_template)
        end
      end
    end
    end
  end
end
