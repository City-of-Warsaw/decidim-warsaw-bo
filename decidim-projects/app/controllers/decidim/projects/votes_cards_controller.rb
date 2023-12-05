# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows users voting for projects
  class VotesCardsController < Decidim::Projects::ApplicationController
    helper Decidim::Projects::VoteWizardHelper
    include Decidim::FormFactory
    include ActiveSupport::NumberHelper

    before_action :check_if_voting_is_enabled

    helper_method :wizard, :vote_card

    # Show form with email address for start voting
    def new
      enforce_permission_to :create, :voting, component: current_component

      @form = form(Decidim::Projects::VoteCardCreateForm).from_params({})
    end

    # Save valid email and send link for voting
    def create
      enforce_permission_to :create, :voting, component: current_component

      @form = form(Decidim::Projects::VoteCardCreateForm).from_params(params[:vote])
      Decidim::Projects::CreateVoteCard.call(@form, current_user, current_component, client_ip) do
        on(:ok) do
          flash[:notice] = I18n.t("votes.create.success", scope: "decidim")
          redirect_to '/projects'
        end

        on(:send_again) do
          flash[:notice] = I18n.t("votes.create.send_again", scope: "decidim")
          redirect_to '/projects'
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("votes.create.error", scope: "decidim")
          render :new
        end
      end
    end

    def edit
      redirect_to root_path, notice: "Głos został już oddany." and return unless vote_card

      enforce_permission_to :edit, :voting, vote_card: vote_card
      @form = form(wizard.edit_form_class).from_model(vote_card)
      @form.scope_id = params[:scope_id] if params[:scope_id]
      update_statistics_timetable
    end

    def update
      enforce_permission_to :edit, :voting, vote_card: vote_card
      @form =  find_update_form

      Decidim::Projects::UpdateVoteCard.call(vote_card, @form, current_user) do
        on(:ok) do |vote_card|
          if wizard.next_step == "step_4" && vote_card.global_projects_ids.none?
            # jesli pominieto projekty ogolnomiejskie to inny komunikat
            flash[:notice] = I18n.t("votes.update.#{wizard.step}.skip_projects", scope: "decidim")
          elsif wizard.next_step.in?(["step_3_info", "step_3_list",]) && vote_card.district_projects_ids.none?
            # jesli pominieto projekty dzielnicowe to inny komunikat
            flash[:notice] = I18n.t("votes.update.#{wizard.step}.skip_projects", scope: "decidim")
          else
            flash[:notice] = I18n.t("votes.update.#{wizard.step}.success", scope: "decidim")
          end
          redirect_to path_for_wizard_vote(vote_card, wizard.next_step)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("votes.update.error", scope: "decidim")
          render :edit
        end
      end
    end

    # get action - submits vote and finishes voting process perceiving data
    def publish
      enforce_permission_to :edit, :voting, vote_card: vote_card
      wizard("step_6")
      @step = "step_6"
      @form = form(Decidim::Projects::WizardVoteCardPublishForm).from_model(vote_card)
      Decidim::Projects::PublishVoteCard.call(vote_card, @form, current_user) do
        on(:ok) do |vote_card|
          flash.now[:notice] = I18n.t("votes.publish.success", scope: "decidim")
          render :publish
        end
        on(:no_projects_selected) do |vote_card|
          flash[:alert] = 'Nie oddano głosu na żaden projekt. Ponów wybór projektów'
          redirect_to path_for_wizard_vote(vote_card, Decidim::Projects::VotingWizard::STEPS::INSTRUCTION)
        end
        on(:invalid) do |vote_card|
          flash[:alert] = I18n.t("votes.publish.error", scope: "decidim")
          redirect_to path_for_wizard_vote(vote_card, Decidim::Projects::VotingWizard::STEPS::USER_DATA)
        end
      end
    end

    # get action - finishes current voting process and clears voting data
    # Action is triggered by:
    # - voting session end
    # - window close
    def finish
      ap "finish - " * 60
      enforce_permission_to :edit, :voting, vote_card: vote_card
      # before unload event should not require redirect
      respond_to do |format|
        format.html { redirect_to decidim.root_path }
        format.js { head :no_content }
      end
    end

    # Called after district change in the "step_2_list" voting step
    def district_projects
      enforce_permission_to :edit, :voting, vote_card: vote_card

      # clear selected district projects, when district is changed
      if vote_card.scope_id&.to_s != params[:scope_id]
        vote_card.project_ids = vote_card.projects.in_global_scope.pluck(:id)
      end
      # save actual scope_id
      vote_card.update_column(:scope_id, params[:scope_id])

      get_district_projects
      @all_locations_json = generate_map_markers(@projects) if @projects

      respond_to do |format|
        # format.html
        format.js { render 'picked_projects.js' }
      end
    end

    # Called:
    # - when opening the list with districts projects
    # - when searching for projects to vote on, after turning on the magnifying glass
    def filtered_projects
      enforce_permission_to :edit, :voting, vote_card: vote_card

      update_statistics_filters_use
      case wizard.step
      when 'step_2', 'step_2_list'
        filter_district_projects
      when 'step_3', 'step_3_list'
        filter_global_scope_projects
      else
        @projects = Decidim::Projects::Project.none
      end

      @all_locations_json = generate_map_markers(@projects) if @projects

      respond_to do |format|
        format.js { render 'picked_projects.js' }
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
                                                .find_by(voting_token: params[:id])
    end

    def wizard(step = params[:step])
      @wizard ||= Decidim::Projects::VotingWizard.new(current_component, step)
    end
    
    def find_update_form
      ap "find_update_form: #{wizard.step}"
      case wizard.step
      when 'step_2_list'
        form(wizard.update_form_class).from_params(params[:wizard_vote_district_projects])
      when 'step_3_list'
        form(wizard.update_form_class).from_params(params[:wizard_vote_global_projects])
      when 'step_4'
        form(wizard.update_form_class).from_params(params[:wizard_vote_user_data])
      else
        form(wizard.update_form_class).from_model(vote_card)
      end
    end

    def update_statistics_timetable
      @statistic = vote_card.retrieve_last_statistic(params[:link_sent])

      params[:link_sent] = nil # clearing for requests
      timetable_key = wizard.step
      @statistic.add_new_time!(timetable_key, DateTime.current)
    end

    def update_statistics_filters_use
      attributes_to_update = wizard.retrieve_filters(params[:search_text], params[:categories], params[:recipients])
      vote_card.last_active_statistic.update(attributes_to_update) unless attributes_to_update.empty?
    end

    def get_district_projects
      scope = Decidim::Scope.find_by(id: params[:scope_id])
      @projects = form(Decidim::Projects::WizardVoteForm)
                  .from_model(vote_card)
                  .listed_district_projects(params[:scope_id])

      @empty_info = scope ? "Brak projektów do wyboru dla dzielnicy <strong>#{scope.name['pl']}<strong>" : nil
      @scope_budget_value = scope ? "Kwota przeznaczona na realizację projektów na poziomie dzielnicowym: <strong>#{budget_to_currency(vote_card.scope_budget_value(params[:scope_id]))}</strong>".html_safe : nil
    end

    def filter_district_projects
      scope = Decidim::Scope.find_by(id: params[:scope_id])
      @projects = scope ? filter_projects(params[:scope_id]) : Decidim::Projects::Project.none
      @empty_info = scope ? "Brak projektów do wyboru dla dzielnicy <strong>#{scope.name['pl']}<strong>" : nil
      @scope_budget_value = scope ? "Kwota przeznaczona na realizację projektów na poziomie dzielnicowym: <strong>#{budget_to_currency(vote_card.scope_budget_value(params[:scope_id]))}</strong>".html_safe : nil
    end

    def filter_global_scope_projects
      @projects = filter_projects(Decidim::Projects::WizardVoteForm::GLOBAL_SCOPE_ID)
      @empty_info = "Brak projektów do wyboru na poziomie <strong>ogólnomiejskim<strong>"
      @scope_budget_value = "Kwota przeznaczona na realizację projektów na poziomie ogólnomiejskim: <strong>#{budget_to_currency(vote_card.global_scope_budget_value)}</strong>".html_safe
    end

    def generate_map_markers(projects)
      cell("decidim/meetings/content_blocks/upcoming_events").generate_map_markers(projects, vote_card, wizard.step).html_safe
    end

    def filter_projects(scope_id)
      search_params = {
        scope_id: scope_id,
        search_text: params[:search_text],
        category: params[:categories],
        potential_recipient: params[:recipients]
      }

      Decidim::Projects::ProjectSearch.new(search_params)
                                      .results
                                      .published
                                      .not_hidden
                                      .chosen_for_voting
                                      .where('decidim_projects_projects.decidim_component_id': current_component.id)
                                      .order(voting_number: :asc)
    end

    def budget_to_currency(budget)
      number_to_currency budget, unit: Decidim.currency_unit, precision: 0
    end

    def client_ip
      request.ip
    end
  end
end
