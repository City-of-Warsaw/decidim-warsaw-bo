# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows users voting for projects
  class VotesController < Decidim::Projects::ApplicationController
    helper Decidim::Projects::VoteWizardHelper
    include Decidim::FormFactory
    include ActiveSupport::NumberHelper

    before_action :check_if_voting_is_enabled

    helper_method :vote_card

    def index
      if params[:global] == '1'
        render json: { ids: vote_card.projects.in_global_scope.pluck(:id).join(',') }.to_json
      else
        render json: { ids: vote_card.projects.in_district_scope.pluck(:id).join(',') }.to_json
      end
    end

    def update
      enforce_permission_to :edit, :voting, vote_card: vote_card

      Decidim::Projects::UpdateVote.call(vote_card, project, current_user) do
        on(:ok) do |vote_ids|
          # district: vote_card.projects.in_district_scope.pluck(:id),
          # global: vote_card.projects.in_global_scope.pluck(:id)
          if params[:global] == '1'
            render json: { ids: vote_card.projects.in_global_scope.where(id: vote_ids).pluck(:id).join(',') }.to_json
          else
            # render json: { ids: vote_ids.join(',') }.to_json
            render json: { ids: vote_card.projects.in_district_scope.where(id: vote_ids).pluck(:id).join(',') }.to_json
          end
        end
        on(:invalid) do
          head :no_content
        end
      end
    end


    private

    def check_if_voting_is_enabled
      unless current_participatory_space.active_step == current_participatory_space.voting_step
        flash[:notice] = "Głosowanie juz zostało zakończone, zapraszamy do głosowania w przyszłej edycji!"
        redirect_to root_path and return
      end
    end

    # params[:id] is generated from token
    def vote_card
      @vote_card ||= Decidim::Projects::VoteCard.where(decidim_component_id: current_component.id)
                                                .with_active_link
                                                .find_by(voting_token: params[:votes_card_id])
    end

    def project
      Decidim::Projects::ProjectsForVoting.for(current_component).find params[:id]
    end

    def update_statistics_timetable
      @statistic = vote_card.retrieve_last_statistic(params[:link_sent])

      params[:link_sent] = nil # clearing for requests
      timetable_key = wizard.step
      @statistic.add_new_time!(timetable_key, DateTime.current)
    end

    def create_log(resource, log_type)
      Decidim.traceability.perform_action!(
        log_type,
        resource,
        current_user,
        visibility: "admin-only"
      )
    end

    def client_ip
      request.ip
    end
  end
end
