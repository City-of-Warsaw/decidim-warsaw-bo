# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when a user creates a new vote.
    class CreateVoteCard < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
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
          create_vote
        end

        broadcast(:ok, @vote)
      end

      private

      attr_reader :form, :current_user

      # Prevent PaperTrail from creating an additional version
      #
      # Creates ActionLog
      #
      # returns Vote
      def create_vote
        PaperTrail.request(enabled: false) do
          @vote = Decidim.traceability.perform_action!(
            :create,
            Decidim::Projects::VoteCard,
            @current_user,
            visibility: "admin-only"
          ) do
            @vote = Decidim::Projects::VoteCard.new(vote_attributes)
            @vote.save
            # projects
            @vote.projects = form.all_picked_projects
            @vote
          end
        end
      end


      # Private: vote attributes
      #
      # returns Hash
      def vote_attributes
        {
          # default data
          author: current_user,
          is_paper: true,
          status: Decidim::Projects::VoteCard::STATUSES::WAITING,
          card_number: Decidim::Projects::VoteCard.generate_card_number(form.component),
          # meta data
          component: form.component,
          scope: form.scope,
          # voter data
          first_name: form.first_name,
          last_name: form.last_name,
          street: form.street,
          street_number: form.street_number,
          flat_number: form.flat_number,
          zip_code: form.zip_code,
          city: form.city,
          pesel_number: form.pesel_number,
          # editor fields
          identity_confirmed: form.identity_confirmed,
          card_signed: form.card_signed,
          data_unreadable: form.data_unreadable,
          card_invalid: form.card_invalid,
          card_received_late: form.card_received_late,
          projects_in_districts_scope: form.global_projects,
          projects_in_global_scope: form.district_projects
        }
      end
    end
  end
end
