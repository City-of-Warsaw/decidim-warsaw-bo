# frozen_string_literal: true

module Decidim
  module Projects
    # Class holds all the logic to verify vote data.
    # It is used in:
    #   Vote Model - for showing list of invalid reasons and warnings
    #   WizardVoteUserDataForm - for validation
    class VoteCardValidityService

      # Public: Initializes the service.
      # vote     - Vote or record in validation
      def initialize(vote_card, list_of_used_pesels = nil)
        @list_of_used_pesels = list_of_used_pesels
        @vote_card = vote_card
        @pesel = Decidim::Projects::PeselValue.new(@vote_card, @vote_card.pesel_number)
      end

      def invalid?
        global_limits_surpassed? || district_limits_surpassed? || card_not_signed? ||
          identity_not_checked? || invalid_card? || unreadable? || card_received_late? ||
          pesel_number_blank? || pesel_invalid? || pesel_used?
      end

      # Public method
      #
      # Method returns Array of reasons of invalidity of the votes card
      def list_vote_invalid_reasons
        reasons = [
          (invalid_message('global_projects_count_exceeded') if global_limits_surpassed?),
          (invalid_message('district_projects_count_exceeded') if district_limits_surpassed?),
          (invalid_message('card_not_signed') if card_not_signed?),
          (invalid_message('identity_not_checked') if identity_not_checked?),
          (invalid_message('pesel_number_invalid') if pesel_invalid?),
          (invalid_message('pesel_used') if pesel_used?),
          (invalid_message('pesel_number_blank') if pesel_number_blank?),
          (invalid_message('invalid_card') if invalid_card?),
          (invalid_message('unreadable') if unreadable?),
          (invalid_message('card_received_late') if card_received_late?)
        ]
        reasons.reject!(&:blank?)
        reasons
      end

      # Public method
      #
      # Method returns Array of warnings for votes card
      #  - city has to be 'Warsaw' (is not case sensitive)
      #  - zip_code after clearing has to have 5 digits
      def list_vote_warnings
        warnings = [
          (warning_message('not_from_warsaw') if not_from_warsaw?),
          (warning_message('wrong_zip_code') if wrong_zip_code?)
        ]
        warnings.reject!(&:blank?)
        warnings
      end

      def global_limits_surpassed?
        @vote_card.global_projects_ids.size > @vote_card.global_scope_projects_voting_limit
      end

      def district_limits_surpassed?
        @vote_card.district_projects_ids.size > @vote_card.district_scope_projects_voting_limit
      end

      def card_not_signed?
        !@vote_card.card_signed && @vote_card.is_paper?
      end

      def identity_not_checked?
        !@vote_card.identity_confirmed && @vote_card.is_paper?
      end

      def pesel_invalid?
        return if pesel_number_blank?

        !@pesel.valid?
      end

      def pesel_used?
        return if pesel_number_blank?

        @pesel.pesel_already_used?(@list_of_used_pesels)
      end

      def pesel_number_blank?
        @vote_card.pesel_number.blank?
      end

      def invalid_card?
        @vote_card.card_invalid && @vote_card.is_paper?
      end

      def unreadable?
        @vote_card.data_unreadable && @vote_card.is_paper?
      end

      def card_received_late?
        @vote_card.card_received_late && @vote_card.is_paper?
      end

      # warnings

      def not_from_warsaw?
        @vote_card.city&.downcase != 'warszawa'
      end

      def wrong_zip_code?
        @vote_card.zip_code.blank? || !(@vote_card.zip_code =~ /\A[0-9]{2}-[0-9]{3}\z/)
      end

      private

      def warning_message(message)
        I18n.t(message, scope: 'activemodel.attributes.vote_card.warning_card_message')
      end

      def invalid_message(message)
        I18n.t(message, scope: 'activemodel.attributes.vote_card.invalid_card_message')
      end
    end
  end
end
