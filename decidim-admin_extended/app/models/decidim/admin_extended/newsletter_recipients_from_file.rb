# frozen_string_literal: true

module Decidim
  module AdminExtended
    class NewsletterRecipientsFromFile < ApplicationRecord
      belongs_to :newsletter, class_name: 'Decidim::Newsletter'
      belongs_to :organization, class_name: 'Decidim::Organization'

      def locale
        organization.default_locale
      end
    end
  end
end
