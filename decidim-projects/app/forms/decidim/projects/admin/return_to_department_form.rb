# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to return  in admin panel.
      class ReturnToDepartmentForm  < Form
        attribute :body, Integer
        attribute :project_id, Integer

        validates :project_id, presence: true

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        def previous_department
          @project.previous_department
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
          self.body = model.return_reason
        end
      end
    end
  end
end
