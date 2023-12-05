# frozen_string_literal: true

Decidim::Meetings::ContentBlocks::UpcomingEventsCell.class_eval do
  include ActionView::Helpers::NumberHelper
  include Decidim::Projects::SharedHelper
  include Decidim::ApplicationHelper
  include Rails.application.routes.mounted_helpers

  def show
    render :show_new
  end

  def all_markers
    generate_map_markers(submitted_projects)
  end

  # render project popup on map
  def map_el(project, vote = nil, step = nil)
    @project = project
    @vote = vote
    @step = step
    render :map_el
  end

  def parsed_for_map_resource_path(proj)
    if @vote
      "/processes/#{proj.participatory_space.slug}/f/#{proj.decidim_component_id}/projects/#{proj.id}?fm=1&step=#{@step}&voting=#{@vote.voting_token}"
    else
      "/processes/#{proj.participatory_space.slug}/f/#{proj.decidim_component_id}/projects/#{proj.id}"
    end
  end

  def submitted_projects
    component_ids = Decidim::ParticipatoryProcess.actual_edition.components.where(manifest_name: 'projects').pluck(:id)

    Decidim::Projects::Project.published.where(decidim_component_id: component_ids).includes(:component)
  end

  def generate_map_markers(projects, vote = nil, step = nil)
    all_locations = {}
    projects.each do |proj|
      next if proj.locations.blank?

      new_loc = generate_map_markers_for_single_project(proj, false, vote, step)
      all_locations = all_locations.merge(new_loc)
    end
    all_locations.to_json
  end

  def generate_map_markers_for_single_project(project, to_json = true, vote = nil, step = nil)
    all_locations = {}
    project.locations.each do |e|
      key = e[0]
      all_locations[key] = {}
      all_locations[key]['lat'] = e[1]['lat']
      all_locations[key]['lng'] = e[1]['lng']
      all_locations[key]['title'] = project.title
      all_locations[key]['popupUrl'] = if vote&.voting_token.present?
                                         "#{Decidim::ResourceLocatorPresenter.new(project).path}/map_details_data?step=#{step}&vote=#{vote.voting_token}"
                                       else
                                         "#{Decidim::ResourceLocatorPresenter.new(project).path}/map_details_data"
                                       end
      all_locations[key]['icon'] = set_icon_name(project)
      all_locations[key]['pId'] = project.id
    end
    to_json ? all_locations.to_json : all_locations
  end

  def set_icon_name(project)
    case controller_name
    when "Decidim::Projects::ProjectsListsController"
      if action_name == 'index'
        'blue'
      elsif action_name == 'realizations'
        implementation_icon_name(project)
      elsif action_name == 'results'
        results_icon_name(project)
      end
    else
      implementation_icon_name(project)
    end
  end

  def implementation_icon_name(project)
    case project.implementation_status
    when 0
      # abandoned
      'gray'
    when 1, 2, 3, 4
      # in_progress
      'blue'
    when 5
      # finished
      'green'
    else
      # default icon
      'blue'
    end
  end

  def results_icon_name(project)
    if project.chosen_for_implementation?
      'green'
    else
      'blue'
    end
  end

  def controller_name
    @controller_name ||= controller.class.name
  end

  def action_name
    @action_name ||= controller.action_name
  end

  def cache_hash
    nil
  end
end
