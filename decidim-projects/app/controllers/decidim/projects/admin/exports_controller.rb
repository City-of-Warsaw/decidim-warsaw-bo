# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing projects in admin panel.
      class ExportsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Projects::Admin::Filterable
        include Decidim::Projects::Admin::ProjectsExport
        include Decidim::Projects::Admin::ProjectsFilteredCollection

        helper Projects::Admin::ProjectBulkActionsHelper

        def projects
          @projects = filtered_collection_projects.includes(:formal_evaluation, :meritorical_evaluation, :appeal, :reevaluation, :scope, :coauthorships)
          create_log(@projects.first, :export_projects)
          respond_to do |format|
            format.html
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=projekty-#{edition_year}.xlsx"
            end
          end
        end

        def authors
          @projects = filtered_collection_projects
          @authors = Decidim::AdminExtended::Admin::AggregateAuthors.new(@projects).call
          create_log(@projects.first, :export_authors)
          respond_to do |format|
            format.html
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=autorzy-#{edition_year}.xlsx"
            end
          end
        end

        def full
          @projects = filtered_collection_projects.includes(:formal_evaluation, :meritorical_evaluation, :appeal, :reevaluation, :scope, :coauthorships)
          create_log(@projects.first, :export_projects_with_authors)
          respond_to do |format|
            format.html
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=projekty-full-#{edition_year}.xlsx"
            end
          end
        end

        private

        def filtered_collection_projects
          @form = form(Decidim::Projects::Admin::ProjectsFilterForm).from_params(params)
          if @form.invalid?
            flash[:alert] = 'Formularz zawiera niepoprawne pola'
            redirect_to projects_path
          end
          Decidim::AdminExtended::FilteredProjects.new(collection, @form).call
        end

        def collection
          @collection ||= collection_filtered_by_user_permission
        end

      end
    end
  end
end
