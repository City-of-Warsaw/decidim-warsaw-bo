# frozen_string_literal: true

module Decidim::AdminExtended
  # BudgetInfoPosition is used to:
  # - provide belongs_to association to their specific BudgetInfoGroup
  # - to store data: present that data in publish view, for applicants
  class BudgetInfoPosition < ApplicationRecord
    has_one_attached :file

    belongs_to :budget_info_group,
               class_name: "Decidim::AdminExtended::BudgetInfoGroup",
               foreign_key: :budget_info_group_id,
               optional: true

    validate :acceptable_file

    scope :published, -> { where(published: true) }
    scope :published_on_main_page, -> { published.where(on_main_site: true) }
    
    scope :sorted_by_weight, -> { order(weight: :asc) }

    def acceptable_file
      return unless file.attached?

      unless file.byte_size <= 50.megabyte
        errors.add(:file, "Maksymalny rozmiar pliku to 50MB")
      end

      acceptable_types = ["image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp", "application/pdf", "application/msword"]
      unless acceptable_types.include?(file.content_type)
        errors.add(:file, "Dozwolne rozszerzenia plików: jpg jpeg gif png bmp pdf doc")
      end
    end

    # Thumbnail for costs site in pages
    def thumbnail_150
      return unless file.attached?

      file.variant(resize: "150x150") if file.variable?
    end

    # Thumbnail for main site
    def thumbnail_180
      return unless file.attached?

      file.variant(resize: "180x180") if file.variable?
    end
  end
end
