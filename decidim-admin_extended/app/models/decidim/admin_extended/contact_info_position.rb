# frozen_string_literal: true

module Decidim::AdminExtended
  # ContactInfoPosition is used to:
  # - provide belongs_to association to their specific ContactInfoGroup
  # - to store data: present that data in publish view, for applicants
  class ContactInfoPosition < ApplicationRecord
    belongs_to :contact_info_group,
               class_name: "Decidim::AdminExtended::ContactInfoGroup",
               foreign_key: :contact_info_group_id,
               optional: true

    scope :published, -> { where(published: true) }
    scope :sorted_by_weight, -> { order(:weight) }
  end
end
