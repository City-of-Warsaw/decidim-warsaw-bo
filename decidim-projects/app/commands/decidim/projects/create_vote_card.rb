# frozen_string_literal: true

module Decidim
  module Projects
    # A command with all the business logic when a user creates a new votes_card.
    class CreateVoteCard < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user
      # current_component - Projects component
      def initialize(form, current_user, current_component, client_ip)
        @form = form
        @email = form.email
        @current_user = current_user
        @current_component = current_component
        @client_ip = client_ip
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid
      # - :send_again if there is an active link for given email
      # - :invalid if form was invalid
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if vote_with_active_link
          send_email_notification(vote_with_active_link)
          return broadcast(:send_again)
        else
          create_votes_card
          send_email_notification(@votes_card)
        end

        broadcast(:ok)
      end

      private

      attr_reader :form, :current_user, :current_component, :email

      # Private method returning vote with active link for given email if it exists
      def vote_with_active_link
        @vote_with_active_link ||= Decidim::Projects::VoteCard.where(decidim_component_id: current_component.id)
                                                              .where(email: email)
                                                              .with_active_link.first
      end

      # private method
      #
      # creating Vote without versioning or ActionLog
      #
      # returns Vote
      def create_votes_card
        @votes_card = Decidim::Projects::VoteCard.create(vote_attributes)
      end

      # private method
      #
      # returns Hash - mapped attributes for vote
      def vote_attributes
        {
          status: Decidim::Projects::VoteCard::STATUSES::LINK_SENT,
          decidim_component_id: current_component.id,
          email: email,
          card_number: Decidim::Projects::VoteCard.generate_card_number(current_component),
          ip_number: client_ip,
          city: 'Warszawa' # default
        }
      end

      def send_email_notification(votes_card)
        Decidim::Projects::VoteMailer.invitation_for_voting(votes_card).deliver_later
      end
    end
  end
end
