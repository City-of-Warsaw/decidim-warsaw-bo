# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to update Implementation in admin panel.
      class ImplementationEditForm < Decidim::Form
        # implementation fields
        attribute :project_id, Integer
        attribute :implementation_body, String
        attribute :implementation_date, Decidim::Attributes::TimeWithZone

        validates :project_id, presence: true
        validates :implementation_body, presence: true
        validates :implementation_date, presence: true

        # Public: maps implementation fields into FormObject attributes
        def map_model(model)
          super
          # we mapping implementation model
          self.implementation_body = model.body
        end

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end
      end
    end
  end
end
