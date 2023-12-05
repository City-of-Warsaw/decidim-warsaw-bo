# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when user confirms his vote card
    class PublishVoteCard < Rectify::Command
      include Decidim::Projects::VoteWizardHelper

      # Public: Initializes the command.
      #
      # vote_card   - A vote card
      # current_user - The current user
      def initialize(vote_card, form, current_user)
        @vote_card = vote_card
        @form = form
        @current_user = current_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid
      # - :send_again if there is an active link for given email
      # - :invalid if form was invalid
      #
      # Returns nothing.
      def call
        return broadcast(:no_projects_selected, vote_card) if vote_card.projects.none?
        return broadcast(:invalid, vote_card) if form.invalid?

        transaction do
          publish_vote_card
          update_statistics_timetable
          finish_vote_statistic
          clean_opened_statistics
          send_email_notifications(@vote_card)
        end

        broadcast(:ok, vote_card)
      end

      private

      attr_reader :vote_card, :form, :current_user

      # private method
      #
      # creating Vote without versioning or ActionLog
      #
      # returns Vote
      def publish_vote_card
        @vote_card.update(vote_attributes)
      end

      # private method
      #
      # returns Hash - mapped attributes for vote
      def vote_attributes
        {
          status: Decidim::Projects::VoteCard::STATUSES::SUBMITTED
        }
      end

      # private method updating last active statistic finish time
      def finish_vote_statistic
        @vote_card.finish_active_statistic!
      end

      # Private method closing all the statistics that were not closed properly
      def clean_opened_statistics
        @vote_card.close_all_opened_statistics!
      end

      # Private method sending email with thank you message
      def send_email_notifications(vote_card)
        Decidim::Projects::VoteMailer.thank_you_for_voting(vote_card).deliver_later
      end
    end
  end
end
