# frozen_string_literal: true

module Decidim
  module AdminExtended
    class FilteredProjects < Rectify::Command
      attr_accessor :states, :project_conflict_ids ,:is_paper, :scope_ids, :verification_statuses, :scope_type_ids, :categories_ids, :recipients_ids, :user_ids, :collection, :q

      def initialize(collection, form)
        self.collection = collection
        self.states = form.states
        self.verification_statuses = form.verification_statuses
        self.scope_type_ids = form.scope_type_ids
        self.scope_ids = form.scope_ids
        self.categories_ids = form.categories_ids
        self.recipients_ids = form.recipients_ids
        self.is_paper = form.is_paper
        self.project_conflict_ids = form.project_conflict_ids
        self.user_ids = form.user_ids.delete_if(&:blank?)
        self.q = form.q
      end

      def call
        filtered_projects
      end

      private

      def filtered_projects
        return Decidim::Projects::Project.none if collection.nil? || collection.empty?

        projects = collection
        projects = filter_evaluator_projects(projects) if user_ids.any?
        projects = filter_type_of_projects(projects) unless is_paper.empty?
        projects = filter_states(projects) if states.any?
        projects = filter_conflicts(projects) if project_conflict_ids.any?
        projects = filter_verification_statuses(projects) if verification_statuses.any?
        projects = filter_scope_type(projects) if scope_type_ids.any?
        projects = filter_scope(projects) if scope_ids.any?

        # projects = filter_categories(projects) unless categories_ids.nil?
        projects = filter_recipients_ids(projects) if recipients_ids.any?
        projects = ransack_search(projects) if q.present?
        return projects.includes(:component, :coauthorships)
      end

      def filter_type_of_projects(projects)
        projects.where(is_paper: is_paper)
      end

      def filter_evaluator_projects(projects)
        projects.where(evaluator_id: user_ids)
      end

      def filter_conflicts(projects)
        projects.where(conflict_status: project_conflict_ids)
      end

      def filter_verification_statuses(projects)
        projects.where(verification_status: verification_statuses)
      end

      def filter_scope_type(projects)
        projects.joins(:scope).where(decidim_scopes: { scope_type_id: scope_type_ids })
      end

      def filter_scope(projects)
        projects.where(decidim_scope_id: scope_ids)
      end

      def filter_categories(projects)
        projects.joins(:project_areas).where(decidim_project_areas: { decidim_area_id: categories_ids })
      end

      def filter_recipients_ids(projects)
        projects.joins(:project_recipients)
                .where(decidim_projects_project_recipients: { decidim_admin_extended_recipient_id: recipients_ids })
      end

      def filter_states(projects)
        projects.where(state: states)
      end

      def ransack_search(projects)
        projects.ransack(q.to_h.deep_symbolize_keys).result
      end

    end
  end
end
