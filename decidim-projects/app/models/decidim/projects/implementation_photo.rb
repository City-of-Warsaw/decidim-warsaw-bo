# frozen_string_literal: true

module Decidim::Projects
  # Contains photos for projects implementations
  class ImplementationPhoto < ApplicationRecord

    has_one_attached :file

    belongs_to :project

    def thumbnail
      return unless file.attached?

      file.variant(resize: "x237") if file.variable?
    end

    def big
      return unless file.attached?

      file.variant(resize: "800x500>") if file.variable?
    end
  end
end
