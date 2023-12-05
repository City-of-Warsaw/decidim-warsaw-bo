# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update faq.
      class FaqGroupForm < Form

        attribute :title, String
        attribute :subtitle, String
        attribute :published, Boolean
        attribute :weight, Integer

        mimic :faq_group

        validates :title, :weight, presence: true
        validates :published, inclusion: { in: [true, false] }
      end
    end
  end
end
