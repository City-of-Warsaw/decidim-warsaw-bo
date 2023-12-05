# frozen_string_literal: true

module Decidim::AdminExtended
  # Recipients are used for managing dictionary of recipients for Projects
  class Recipient < ApplicationRecord
    has_many :project_recipients,
              class_name: "Decidim::Projects::ProjectRecipient",
              foreign_key: :decidim_admin_extended_recipient_id,
              dependent: :destroy

    scope :sorted_by_name, -> { order(:name) }
    scope :active, -> { where(active: true) }

    validates :name, presence: true
  end
end
