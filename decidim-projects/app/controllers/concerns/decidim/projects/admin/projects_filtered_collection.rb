# frozen_string_literal: true

require 'active_support/concern'

module Decidim
  module Projects
    module Admin
      # This ProjectsExport contains logic for projects export in admin panel
      module ProjectsFilteredCollection
        extend ActiveSupport::Concern

        included do
          helper_method :collection_filtered_by_user_permission

          private

          def collection_filtered_by_user_permission
            projects_filtered = Decidim::Projects::ProjectsFromEdition.for(current_component)
            if current_user.ad_admin?
              projects_filtered.esog_sorted
            elsif current_user.ad_coordinator?
              # show only projects assigned CURRENTLY to the department via scope or current department
              # or strictly to the coordinator
              if current_user.department
                # we need
                # - all via scope (not any user has it)
                # - all via evaluator
                # - all via current sub_coordinance
                # - all via current department
                ids = projects_filtered
                        .where.not(decidim_scope_id: nil)
                        .where(decidim_scope_id: current_user.assigned_scope_id)
                        .or(projects_filtered.where(evaluator: current_user))
                        .or(projects_filtered.where(current_sub_coordinator: current_user))
                        .or(projects_filtered.where.not(current_department_id: nil).where(current_department: current_user.department))
                        .pluck(:id).uniq
                Project.where(id: ids).esog_sorted
              else
                Project.none
              end
            elsif current_user.ad_sub_coordinator?
              ids = projects_filtered.where(evaluator: current_user)
                                     .or(projects_filtered.where(current_sub_coordinator: current_user))
                                     .pluck(:id).uniq
              Project.where(id: ids).esog_sorted
            else
              # for verifier
              ids = current_user.assigned_projects.uniq.pluck(:id)
              projects_filtered.where(id: ids).esog_sorted
            end
          end

        end
      end
    end
  end
end
