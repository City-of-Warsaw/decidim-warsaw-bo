# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to manually update projects status in admin panel.
      class ProjectConflictForm  < Form

        attribute :project_id, Integer
        attribute :project_ids, Array
        attribute :conflict_status, String

        validates :project_id, presence: true

        def if_conflicted_projects_any
          errors.add(:project_ids, 'Należy wskazać conajmniej jeden projekt') if project_ids.none?
        end

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super

          # Attributes with different keys, so they
          # have to be manually mapped.
          self.project_id = model.id
          self.project_ids = model.projects_in_conflict.pluck(:id)
        end

        def project_title
          "[#{project.scope.name['pl'] if project.scope}] #{project.voting_number} - #{project.title} (#{project.esog_number})"
        end

        # return projects for select:
        # - for citywide project should return all projects
        # - for district - only citywide projects and projects from this district
        def projects_for_select
          @projects_for_select ||= begin
                                     projects = Decidim::Projects::ProjectsForVoting.new(current_component).query.where.not(id: project_id)
                                     if Decidim::Scope.citywide.id != project.decidim_scope_id
                                       projects = projects.where(decidim_scope_id: [Decidim::Scope.citywide.id, project.decidim_scope_id])
                                     end
                                     projects.order(decidim_scope_id: :asc, voting_number: :asc).map do |project|
                                       ["[#{project.scope.name['pl'] if project.scope}] #{project.voting_number} - #{project.title} (#{project.esog_number})", project.id]
                                     end
                                   end
        end

        def project
          Decidim::Projects::Project.find_by(id: project_id)
        end

        def conflicted_projects
          Decidim::Projects::Project.where(id: project_ids)
        end
      end
    end
  end
end
