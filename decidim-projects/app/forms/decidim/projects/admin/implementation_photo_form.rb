# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create Implementation in admin panel.
      class ImplementationPhotoForm < Decidim::Form
        mimic :implementation_photo

        attribute :project_id, Integer
        attribute :model
        attribute :alt, String

        validates :alt, presence: true

        # Public: maps attachment fields into FormObject attributes
        def map_model(model)
          super

          # The scope attribute is with different key (decidim_scope_id), so it
          # has to be manually mapped.
          self.model = model
          self.project_id = model.project_id if model.project_id
          self.alt = model.image_alt
        end

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end
      end
    end
  end
end
