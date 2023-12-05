# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to assign project to the evaluator in admin panel.
      class ChooseVerificatorForm  < Form
        attribute :evaluator_id, Integer
        attribute :project_id, Integer

        validates :evaluator_id, presence: true

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        def possible_verifacator_ids
          return [] unless department

          verificators = department.verificators.or(department.sub_coordinators).or(department.coordinators)
          verificators.with_ad_access.order(ad_role: :asc, first_name: :asc).map{ |user| ["#{user.department&.name} - #{user.ad_full_name}", user.id] }.uniq
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
        end

        # Public: returns Object - Current department of the project or
        # Department based on the project's scope
        def department
          @department ||= project.current_department || project.scope&.department
        end
      end
    end
  end
end
