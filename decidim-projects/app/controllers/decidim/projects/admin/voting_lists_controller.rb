# frozen_string_literal: true

module Decidim::Projects
  class Admin::VotingListsController < Admin::ApplicationController
    include Decidim::ApplicationHelper
    include Decidim::Projects::Admin::VotingListFilterable

    before_action :initialize_search_params

    helper_method :projects, :scope, :asset_file_path, :scope_districts, :projects_city_wide

    # lista projektow do glosowania w podziale na ogolnomiejskie i dzielnicowe
    def index
      enforce_permission_to :read, :voting_list
      @projects = filtered_collection.includes(:scope)
      @projects = paginate(@projects)
    end

    # generuje listy do glosowania, jeszcze przed rozpoczeciem glosowania
    def generate_voting_numbers
      enforce_permission_to :generate_voting_numbers, :projects, component: current_component

      Decidim::Projects::Admin::GenerateVotingNumbers.call(current_component, current_user) do
        on(:ok) do
          flash[:notice] = 'Wygenerowano numery do głosowania dla projektów.'
        end
        on(:invalid) do
          flash.now[:alert] = 'Nie udało się wygenerować numerów do głosowania dla projektów.'
        end
      end
      redirect_to voting_lists_path
    end

    def export
      @projects = filtered_collection.includes(:scope).except(:limit, :offset)
      enforce_permission_to :read, :voting_list

      #Logging action needs to have resource - for show/list its first/any item
      create_log(@projects.first, :export_voting_list) if @projects.any?

      @scope_title = if scope.citywide?
                       "POZIOM OGÓLNOMIEJSKI"
                    else
                      "W DZIELNICY " + translated_attribute(scope.name).upcase
                    end
      respond_to do |format|
        format.xlsx {
          response.headers['Content-Disposition'] = "attachment; filename=lista-#{translated_attribute(scope.name)}.xlsx"
        }
        format.pdf {
          render pdf: "lista-#{translated_attribute(scope.name)}", disposition: 'attachment'
        }
      end
    end
    def export_voting_card
      enforce_permission_to :export_voting_card, :projects, component: current_component
      @projects = filtered_collection.includes(:scope).except(:limit, :offset)

      #Logging action needs to have resource - for show/list its first/any item
      create_log(projects.first, :export_voting_card) if projects.any?

      respond_to do |format|
        format.pdf do
          render pdf: "karta-dzielnicy-#{translated_attribute(scope.name)}",
                 disposition: 'attachment',
                 javascript_delay: 1000,
                 footer: {
                   font_name: "Arial",
                   font_size: 8,
                   center: 'Strona [page] / [topage]'
                 }
        end
      end
    end

    private

    # find selected scope, if none was choosen then global scope is set as default
    # return Decidim::Scope
    def scope
      @scope ||= begin
                   scope_id = params.dig(:q, :scope_id_eq)
                   Decidim::Scope.find_by(id: scope_id)
                 end
    end

    def projects_city_wide
      @collection.where(decidim_scope_id: Decidim::Projects::Project::GLOBAL_SCOPE_ID).order(voting_number: :asc)
    end

    def scope_districts
      Decidim::Projects::DistrictScopes.new.query
    end

    def collection
      @collection = Decidim::Projects::ProjectsForVoting.new(current_component).query
    end

    # Private: filters collection of projects
    def projects
      @projects ||= filtered_collection.includes(:scope)
    end

    def asset_file_path(image)
      t = Tempfile.new(['my_image','.png'])
      t.binmode
      t.write open(File.join(Rails.public_path, ApplicationController.helpers.asset_path(image))).read
      t.rewind
      t.path
    end

    def initialize_search_params
      params[:q] = {} if params[:q].blank?
      # init default sorting by voting_number asc
      params[:q][:s] = 'voting_number asc' if params[:q][:s].blank?
      # init default scope to global
      params[:q][:scope_id_eq] = Decidim::Projects::Project::GLOBAL_SCOPE_ID if params[:q][:scope_id_eq].blank?
    end

    def create_log(resource, log_type)
      Decidim::ActionLogger.log(
        log_type,
        current_user,
        resource,
        nil,
        { visibility: "admin-only" }
      )
    end
  end
end
