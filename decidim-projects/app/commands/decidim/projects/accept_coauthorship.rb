# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user accepts coauthorship od the project.
    class AcceptCoauthorship < Rectify::Command
      # Public: Initializes the command.
      #
      # coauthorship     - The coauthorsip to accept
      # form             - Form Object
      # current_user     - The current user.
      def initialize(coauthorship, form, current_user)
        @coauthorship = coauthorship
        @form = form
        @project = coauthorship.coauthorable
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the project.
      # - :invalid if form is invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?

        transaction do
          update_user_data
          update_coauthor_data
          accept_coauthorship
          # send_notification
        end

        broadcast(:ok, @project)
      end

      private

      # private method
      #
      # updating Coauthorship status to 'confirment' and acceptance data to Date.current
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

      # private method
      #
      # updating User with data provided in form
      def update_user_data
        # skipping validations
        @current_user.update_columns(
          # agreements
          email_on_notification: @form.email_on_notification || @current_user.inform_me_about_proposal
        )
      end

      def update_coauthor_data
        if project.coauthorships.for_acceptance.first&.author&.email == @current_user.email
          project.update_column :coauthor1_data, coauthor_data_attrs
        elsif project.coauthorships.for_acceptance.last&.author&.email == @current_user.email
          project.update_column :coauthor2_data, coauthor_data_attrs
        end
      end

      def coauthor_data_attrs
        {
          email: @current_user.email,
          first_name: @form.first_name,
          last_name: @form.last_name,
          gender: @form.gender,
          phone_number: @form.phone_number,
          street: @form.street,
          street_number: @form.street_number,
          flat_number: @form.flat_number,
          zip_code: @form.zip_code,
          city: @form.city,
          # agreements
          show_author_name: ActiveModel::Type::Boolean.new.cast(@form.show_author_name),
          inform_author_about_implementations: ActiveModel::Type::Boolean.new.cast(@form.inform_author_about_implementations)
        }
      end
    end
  end
end
