# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update contact info position.
      class ContactInfoPositionForm < Form

        attribute :name, String
        attribute :position, String
        attribute :phone, String
        attribute :email, String
        attribute :published, Boolean
        attribute :weight, Integer

        attribute :contact_info_group_id, Integer

        mimic :contact_info_position

        validates :name, :position, :phone, :weight, :contact_info_group_id, presence: true
        validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
        validates :published, inclusion: { in: [true, false] }
      end
    end
  end
end
