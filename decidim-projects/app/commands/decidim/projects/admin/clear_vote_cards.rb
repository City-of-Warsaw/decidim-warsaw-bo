# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A command with all the business logic when admin clear all vote card/voters data
    class ClearVoteCards < Rectify::Command

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # current_space - ParticipatorySpace (Process)
      def initialize( current_user)
        @current_user = current_user
      end

      # Executes the command. Broadcasts event:
      #
      # - :ok when everything is valid, together with the appeal.
      # Returns nothing.
      def call
        transaction do
          clear_users_data
          create_log(current_user, 'remove_voters_cards')
        end
        broadcast(:ok)
      end

      private

      attr_reader :projects, :current_user

      # private method for creating logs
      # params:
      # resource - The resource model on which action was performed
      # log_type - name of action - String or Symbol
      def create_log(resource, log_type)
        Decidim.traceability.perform_action!(
          log_type,
          resource,
          current_user,
          visibility: "admin-only"
        )
      end
      # Private method clearing users data:
      #  - Removing data imported as Voter
      #  - Removing users data from votes
      def clear_users_data
        # clearing imported data
        Decidim::Projects::Voter.delete_all
        Decidim::Projects::VoteCard.clear_user_data
      end
    end
  end
end
