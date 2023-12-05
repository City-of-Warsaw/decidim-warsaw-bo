# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update banned words.
      class BannedWordForm < Form
        attribute :name, String

        validates :name, presence: true
      end
    end
  end
end
