# frozen_string_literal: true

module Decidim
  module Projects
    # PosterTemplate is a model used for creating various templates for posters
    # It is defined for Participatory Process.
    class PosterTemplate < ApplicationRecord
      has_one_attached :background_file

      belongs_to :process,
                 class_name: 'Decidim::ParticipatoryProcess',
                 foreign_key: :decidim_participatory_process_id

      scope :published, -> { where(published: true) }

      def thumbnail_150
        return unless background_file.attached?

        background_file.variant(resize: '150x150') if background_file.variable?
      end
      def background
        ActiveStorage::Blob.service.send(:path_for, self.background_file.blob.key)
      end
    end
  end
end
