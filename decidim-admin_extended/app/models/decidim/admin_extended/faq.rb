# frozen_string_literal: true

module Decidim::AdminExtended
  # Faq is used to:
  # - provide belongs_to association to their specific FaqGroup
  # - to store data: present that data in publish view, for applicants
  class Faq < ApplicationRecord
    belongs_to :faq_group,
               class_name: "Decidim::AdminExtended::FaqGroup",
               foreign_key: :faq_group_id,
               optional: true
               
    scope :published, -> { where(published: true) }
    scope :sorted_by_weight, -> { order(:weight) }
  end
end
