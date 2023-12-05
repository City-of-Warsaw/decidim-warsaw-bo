# frozen_string_literal: true
module Decidim::AdminExtended
  # Document is used for managing document
  class Document < ApplicationRecord
    has_one_attached :file

    belongs_to :folder,
               class_name: "Decidim::AdminExtended::Folder",
               foreign_key: :folder_id,
               optional: true

    scope :latest_first, -> { order(created_at: :asc) }
    scope :for_coordinators, -> { where(coordinators: true) }
    scope :for_sub_coordinators, -> { where(sub_coordinators: true) }
    scope :for_verifiers, -> { where(verifiers: true) }
    scope :for_editors, -> { where(editors: true) }

    validate :acceptable_file

    def map_roles
      Decidim::AdminExtended::Admin::DocumentForm::ROLES.inject([]) do |result, role|
        result << role if self.send(role)
        result.size == 4 ? ['all'] : result
      end
    end

    def self.for_user(user)
      if user.ad_admin?
        all
      elsif user.ad_coordinator?
        for_coordinators
      elsif user.ad_sub_coordinator?
        for_sub_coordinators
      elsif user.ad_verifier?
        for_verifiers
      elsif user.ad_editor?
        for_editors
      else
        none
      end
    end

    def acceptable_file
      return unless file.attached?

      unless file.byte_size <= 50.megabyte
        errors.add(:file, "Maksymalny rozmiar pliku to 50MB")
      end

      acceptable_types = ["image/jpg", "image/jpeg", "image/gif", "image/png", "image/bmp", "application/pdf","application/zip", "application/msword"]
      unless acceptable_types.include?(file.content_type)
        errors.add(:file, "Dozwolne rozszerzenia plików: jpg jpeg gif png bmp pdf doc zip")
      end
    end
  end
end
