# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    # ScopeBudget sets a budget limit for each scope
    class EndorsementListSetting < ApplicationRecord
      belongs_to :participatory_process,
                 foreign_key: 'decidim_participatory_process_id',
                 class_name: 'Decidim::ParticipatoryProcess'

      has_one_attached :image_header

      validate :acceptable_image_header

      def acceptable_image_header
        return unless image_header.attached?

        errors.add(:image_header, 'Maksymalny rozmiar pliku to 10MB') unless image_header.byte_size <= 10.megabyte

        acceptable_types = ['image/jpg', 'image/jpeg', 'image/png']
        unless acceptable_types.include?(image_header.content_type)
          errors.add(:image_header, 'Dozwolne rozszerzenia plików: jpg jpeg png')
        end
      end

      def thumbnail_150
        return unless image_header.attached?

        image_header.variant(resize: 'x150') if image_header.variable?
      end
    end
  end
end
