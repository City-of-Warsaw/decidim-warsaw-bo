# # frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user updates vote status manually.
      class UpdateVoteStatus < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # vote         - the vote to update.
        # current_user - the current_user to update.
        def initialize(form, vote, current_user)
          @form = form
          @vote = vote
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_vote
          end

          broadcast(:ok, vote)
        end

        private

        attr_reader :form, :vote

        # Private: updating vote
        #
        # Method does not create version.
        # It adds ActionLog
        #
        # returns vote
        def update_vote
          PaperTrail.request(enabled: false) do
            @vote = Decidim.traceability.perform_action!(
              :change_status,
              vote,
              current_user,
              visibility: "admin-only"
            ) do
              vote.update(vote_params)
              vote
            end
          end
        end

        # Private: vote params
        #
        # returns Hash
        def vote_params
          {
            status: form.status,
            publication_time: publication_time,
            publisher_id: publisher_id
          }
        end

        # Private: returns publication date
        #
        # Method returns publication date based on it's current status
        # and new status
        #
        # returns Time or nil
        def publication_time
          return if form.status == Decidim::Projects::VoteCard::STATUSES::WAITING

          if @vote.is_paper && @vote.publication_time.blank?
            DateTime.current
          else
            @vote.publication_time
          end
        end

        # Private: returns publication date
        #
        # Method returns publication date based on it's current status
        # and new status
        #
        # returns Time or nil
        def publisher_id
          return if form.status == Decidim::Projects::VoteCard::STATUSES::WAITING

          if @vote.is_paper && @vote.publisher_id.blank?
            current_user.id
          else
            @vote.publisher_id
          end
        end
      end
    end
  end
end
