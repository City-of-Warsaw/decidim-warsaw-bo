# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to forward project to a different department in admin panel.
      class ChooseDepartmentForm  < Form
        attribute :department_id, Integer
        attribute :project_id, Integer

        validates :department_id, presence: true

        # Public: sets Project
        def project
          @project ||= Decidim::Projects::Project.find_by(id: project_id)
        end

        def possible_department
          if current_user.ad_admin?
            Decidim::AdminExtended::Department
          elsif current_user.ad_coordinator?
            current_user.department.departments
          else
            Decidim::AdminExtended::Department.none
          end
        end

        def department_types
          {
            "Dzielnice" => possible_department.district_type.with_ad_name.active.sorted_by_name.map{ |item| [item.name, item.id] },
            "Jednostki ogólnomiejskie" => possible_department.general_municipal_unit_type.with_ad_name.active.sorted_by_name.map{ |item| [item.name, item.id] },
            "Biura" => possible_department.office_type.with_ad_name.active.sorted_by_name.map{ |item| [item.name, item.id] },
            "Jednostki dzielnicowe" => possible_department.district_unit_type.with_ad_name.active.sorted_by_name.map{ |item| [item.name, item.id] }
          }
        end

        def possible_departments
          if department
            if current_user.ad_admin?
              department_types
            elsif current_user.ad_coordinator?
              department_types
            else
              []
            end
          else
            current_user.ad_admin? ? department_types : []
          end
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
