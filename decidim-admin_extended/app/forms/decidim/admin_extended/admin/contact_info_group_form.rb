# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update contact info group.
      class ContactInfoGroupForm < Form

        attribute :name, String
        attribute :subtitle, String
        attribute :published, Boolean
        attribute :weight, Integer

        mimic :contact_info_group

        validates :name, :weight, presence: true
        validates :published, inclusion: { in: [true, false] }
      end
    end
  end
end
