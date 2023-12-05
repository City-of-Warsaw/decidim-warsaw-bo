# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to assign project to the sub-coordinator in admin panel.
      class ChooseUserForm  < Form
        attribute :user_id, Integer
        attribute :project_id, Integer

        validates :user_id, presence: true

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        def possible_sub_coordinator_ids
          return [] unless department

          # only for assigning sub_coordinators
          users = []
          department.sub_coordinators.with_ad_access.each{ |user| users << [user.ad_full_name, user.id] }
          users.uniq
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
        end

        # Public: returns Object - Current department of the Project
        # or Department based on the project's scope
        def department
          @department ||= project.current_department || project.scope&.department
        end
      end
    end
  end
end
