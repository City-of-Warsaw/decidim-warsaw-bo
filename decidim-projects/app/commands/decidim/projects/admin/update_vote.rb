# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user updates a vote.
    class UpdateVote < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, vote, current_user)
        @form = form
        @vote = vote
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          update_vote
        end

        broadcast(:ok, @vote)
      end

      private

      attr_reader :form, :current_user, :vote

      # Prevent PaperTrail from creating an additional version
      #
      # Creates ActionLog
      #
      # returns Vote
      def update_vote
          @vote = Decidim.traceability.perform_action!(
            :update,
            @vote,
            @current_user,
            visibility: "admin-only"
          ) do
            @vote.update(vote_attributes)
            # projects
            @vote
          end
      end


      # Private: vote attributes
      #
      # returns Hash
      def vote_attributes
        {
          # meta data
          component: vote.component,
          scope: form.scope,
          projects: form.all_picked_projects,
          # voter data
          first_name: form.first_name,
          last_name: form.last_name,
          street: form.street,
          street_number: form.street_number,
          flat_number: form.flat_number,
          zip_code: form.zip_code,
          city: form.city,
          email: form.email,
          pesel_number: form.pesel_number,
          # editor fields
          identity_confirmed: form.identity_confirmed,
          card_signed: form.card_signed,
          data_unreadable: form.data_unreadable,
          card_invalid: form.card_invalid,
          card_received_late: form.card_received_late,
          projects_in_districts_scope: form.district_projects,
          projects_in_global_scope: form.global_projects
        }
      end
    end
  end
end
