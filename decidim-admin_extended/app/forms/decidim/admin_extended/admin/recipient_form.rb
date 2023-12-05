# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update recipient.
      class RecipientForm < Form

        attribute :name, String
        attribute :active, GraphQL::Types::Boolean

        mimic :recipient

        validates :name, presence: true
      end
    end
  end
end
