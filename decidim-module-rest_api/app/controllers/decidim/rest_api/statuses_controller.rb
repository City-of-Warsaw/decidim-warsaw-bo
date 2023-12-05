# frozen_string_literal: true

require_dependency "decidim/rest_api/application_controller"

module Decidim::RestApi
  class StatusesController < ApplicationController

    # participatory_process_steps:
    # 1.	submitting projects
    # 2.	rating projects
    # 3.	voting
    # 4.	results

    def show
      edition = Current.actual_edition
      projects = Decidim::Projects::Project.where(decidim_component_id: edition.published_project_component&.id)
      projects = projects.published
                         .not_hidden
                         .esog_sorted
      projects_total = projects.count

      active_step = edition.steps.find{ |n| n.active_step? }

      render json: {
        description: 'Dziękujemy za zgłoszone projekty! Rozpoczęła się ich ocena',
        status: step_title(active_step),
        projectsInExecution: projects_total
      }
    end

    private

    def step_title(active_step)
      case active_step.system_name
      when "submitting" then 'Zgłaszanie pomysłów'
      when "rating" then 'Ocena pomysłów'
      when "voting" then 'Głosowanie'
      when "results" then 'Wyniki głosowania'
      when "realization" then 'Wyniki głosowania'
      end
    end
  end
end
