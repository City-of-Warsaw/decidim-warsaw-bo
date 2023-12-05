# frozen_string_literal: true

module Decidim
  module Projects::Admin
    # A form object to import Voters in admin panel.
    class VotersImportForm < Decidim::Form
      mimic :voters_import

      attribute :file
      attribute :remove_voters_only, Boolean

      validate :form_filled

      def remove_voters_only?
        remove_voters_only
      end

      private

      def form_filled
        errors.add(:file, 'Nie wypełniono żadnego z pól formularza') if file.blank? && !remove_voters_only
        errors.add(:file, "Wymagany jest plik CSV (aktualnie: #{file.content_type})") if file.present? && file.content_type != 'text/csv'
        errors.add(:file, 'Plik jest nieprawidłowy') if file.present? && file.size == 0
      end
    end
  end
end
