# frozen_string_literal: true

module Decidim::AdminExtended
  # FaqGroup is used to:
  # - provide has_many association for various Faqs
  # - to store data: groupes which store faqs
  class FaqGroup < ApplicationRecord
    has_many :faqs,
             class_name: "Decidim::AdminExtended::Faq",
             foreign_key: :faq_group_id

    scope :published, ->() { where(published: true) }
    scope :sorted_by_weight, -> { order(:weight) }  
  end
end
