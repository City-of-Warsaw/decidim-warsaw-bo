# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to manage notes added to project in admin panel.
      class AddNoteForm  < Form
        attribute :body, Integer
        attribute :project_id, Integer

        validates :project_id, presence: true

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
          self.body = model.evaluation_note
        end
      end
    end
  end
end
