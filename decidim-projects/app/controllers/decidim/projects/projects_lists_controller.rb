# frozen_string_literal: true

module Decidim::Projects
  # Controller that renders projects list views:
  #  - all projects
  #  - all implementations (realizations)
  #  - all results (of voting)
  class ProjectsListsController < Decidim::ApplicationController
    include Decidim::FormFactory
    include Decidim::FilterResource
    helper Decidim::FiltersHelper
    include Decidim::Projects::Paginable

    def index
      state
      @year = params[:edition_year].present? ? params[:edition_year] : year(Decidim::ParticipatoryProcess.actual_edition.edition_year)
      published_component_ids = Decidim::Component.joins(:published_process).pluck(:id)
      @base_query = search
                    .results
                    .where(decidim_component_id: published_component_ids)
                    .published
                    .not_hidden
                    .esog_sorted

      @projects = @base_query.includes(:component, :coauthorships, :scope, :categories)
      @all_geocoded_projects = @base_query.geocoded
      @all_locations_json = generate_map_markers(@projects)

      @all_projects_count = @projects.count
      @projects = paginate(@projects)

      # respond_to do |format|
      #   format.html
      #   format.js
      # end
    end

    def realizations
      @year = params[:edition_year].present? ? params[:edition_year] : Date.current.year
      @base_query = search
                    .results
                    .published
                    .not_hidden
                    .implementations
                    .esog_sorted

      # For TESTS only
      # @base_query = Rails.env.production? ? @base_query.where(id: [25701, 25685]) : @base_query.where(id: [5852, 5846])

      @projects = @base_query.includes(:component, :coauthorships, :scope, :categories)
      @all_geocoded_projects = @base_query.geocoded
      @all_locations_json = generate_map_markers(@projects)

      @all_projects_count = @projects.count
      @projects = paginate(@projects)
    end

    def results
      # state
      # state('finished')
      @base_query = search
                    .results
                    .published
                    .not_hidden
                    .chosen_for_voting
                    .order('votes_count desc NULLS last')

      # For TESTS only
      # @base_query = Rails.env.production? ? @base_query.where(id: [19567, 22277, 17271]) : @base_query.where(id: [2464, 169, 5183])

      @projects = @base_query.includes(:component, :coauthorships)
      @all_locations_json = generate_map_markers(@projects)

      @all_projects_count = @projects.count
      @projects = paginate(@projects)
    end

    private

    def search_klass
      Decidim::Projects::ProjectSearch
    end

    def state(value = '')
      @state ||= value
    end

    def year(value = 'all')
      @year ||= value
    end

    def permission_scope
      :public
    end

    def default_search_params
      {
        page: params[:page],
        per_page: per_page
      }
    end

    def default_filter_params
      {
        search_text: '',
        # activity: "all",
        state: state,
        implementation_state: '',
        category: 'all',
        scope_id: 'all',
        scope_type: 'all',
        edition_year: year,
        potential_recipient: '',
        per_page: per_page
      }
    end

    def generate_map_markers(projects)
      # all_locations = {}
      # # projects.where.not(locations: {}).map(&:locations).each do |proj_loc|
      # #   all_locations = all_locations.merge(proj_loc)
      # # end
      # projects.where.not(locations: {}).each do |proj|
      #   # new_loc = proj.locations.each { |e| e[1]['display_name'] = (partial: 'decidim/projects/projects/map_el' locals: { project: proj }) }
      #   all_locations = all_locations.merge(new_loc)
      # end
      # all_locations.to_json

      cell("decidim/meetings/content_blocks/upcoming_events").generate_map_markers(projects).html_safe
    end
  end
end
