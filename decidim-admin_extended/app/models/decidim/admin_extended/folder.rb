# frozen_string_literal: true
module Decidim::AdminExtended
  # Folder is used for managing folder
  class Folder < ApplicationRecord
    has_many :documents,  
             class_name: "Decidim::AdminExtended::Document",
             foreign_key: :folder_id,
             dependent: :nullify

    scope :order_by_name, -> { order(name: :asc) }

    validates :name, presence: true
  end
end
