# frozen_string_literal: true

module Decidim::AdminExtended
  # ContactInfoGroup is used to:
  # - provide has_many association for various ContactInfoPositions
  # - to store data: groupes which store positions
  class ContactInfoGroup < ApplicationRecord
    has_many :contact_info_positions,
             class_name: "Decidim::AdminExtended::ContactInfoPosition",
             foreign_key: :contact_info_group_id

    scope :published, -> { where(published: true) }
    scope :sorted_by_weight, -> { order(:weight) }
  end
end
