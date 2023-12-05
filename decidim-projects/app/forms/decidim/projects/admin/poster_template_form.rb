# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Poster Template in admin panel.
      class PosterTemplateForm < Form
        attribute :title, String
        attribute :subtitle, String

        attribute :published, Boolean

        attribute :decidim_participatory_process_id, Integer

        attribute :id, Integer
        attribute :width, Integer
        attribute :height, Integer

        attribute :background_file

        attribute :project_title_x, Integer
        attribute :project_title_y, Integer
        attribute :project_title_width, Integer
        attribute :project_title_height, Integer
        attribute :project_title_css, String

        attribute :project_area_x, Integer
        attribute :project_area_y, Integer
        attribute :project_area_width, Integer
        attribute :project_area_height, Integer
        attribute :project_area_css, String

        attribute :project_number_x, Integer
        attribute :project_number_y, Integer
        attribute :project_number_height, Integer
        attribute :project_number_width, Integer
        attribute :project_number_css, String

        attribute :body_css, String
        attribute :sample_title, String
        attribute :sample_project_number, String
        attribute :sample_project_area, String

        validates :title, presence: true
        validates :published, inclusion: { in: [ true, false ] }
        validates :width, :height,  numericality: { only_integer: true }, presence: true
        validates :project_title_x, :project_title_y, :project_title_width, numericality: { only_integer: true }, presence: true
        validates :project_area_x, :project_area_y, :project_area_width, numericality: { only_integer: true }, presence: true
        validates :project_number_x, :project_number_y, :project_number_width, :project_title_height, numericality: { only_integer: true }, presence: true
        validates :background_file, presence: true, if: proc { |attrs| attrs[:id].nil? }

        validate :acceptable_background_file

        def acceptable_background_file
          return if background_file.nil?

          errors.add(:background_file, 'Maksymalny rozmiar pliku to 10MB') unless background_file.size <= 10.megabyte

          acceptable_types = ['image/jpg', 'image/jpeg', 'image/png']
          unless acceptable_types.include?(background_file.content_type)
            errors.add(:background_file, 'Dozwolne rozszerzenia plików: jpg jpeg png')
          end
        end

        def scopes
          og = Decidim::Projects::DistrictScopes.new.citywide_scope
          mapped = Decidim::Projects::DistrictScopes.new.query.sort { |a, b| a.name['pl'] <=> b.name['pl'] }
          [og] + mapped
        end
      end
    end
  end
end
