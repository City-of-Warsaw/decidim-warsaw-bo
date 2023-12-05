# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing votes in admin panel.
      class VotesCardsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Projects::Admin::VotesFilterable
        include Decidim::Projects::Admin::VotesCardsHelper

        helper_method :votes, :query, :vote, :for_project, :vote_card_validity

        def index
          # Logging action needs to have resource - for show/list its first/any item
          create_log(votes.first, :voting_index) if votes.any?
        end

        def show
          enforce_permission_to :read, :votes, vote: vote
          create_log(vote, :show_single_vote)
        end

        def new
          enforce_permission_to :create, :votes, component: current_component
          @form = form(Decidim::Projects::Admin::VoteForm).from_params(
            city: 'Warszawa',
            component: current_component
          )
        end

        def fetch_projects_via_scope
          enforce_permission_to :create, :votes, component: current_component
          scope = Decidim::Scope.find_by(id: params[:scope_id])
          @projects = form(Decidim::Projects::Admin::VoteForm).from_params(
            component: current_component
          ).district_scope_projects_for_select(scope)

          respond_to do |format|
            format.js
          end
        end

        def create
          enforce_permission_to :create, :votes, component: current_component
          @form = form(Decidim::Projects::Admin::VoteForm).from_params(vote_params.merge(component: current_component))

          Decidim::Projects::Admin::CreateVoteCard.call(@form, current_user) do
            on(:ok) do |vote|
              flash[:notice] = 'Dodano głos'
              redirect_to votes_card_path(vote)
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się utworzyć głosu.'
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :edit, :votes, vote: vote
          @form = form(Decidim::Projects::Admin::VoteForm).from_model(vote)
        end

        def update
          enforce_permission_to :edit, :votes, vote: vote
          @form = form(Decidim::Projects::Admin::VoteForm).from_params(vote_params.merge(component: current_component))

          Decidim::Projects::Admin::UpdateVote.call(@form, vote, current_user) do
            on(:ok) do |vote|
              flash[:notice] = 'Zaktualizowano głos'
              redirect_to votes_card_path(vote)
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaktualizować głosu.'
              render :edit
            end
          end
        end

        def publish
          enforce_permission_to :publish, :votes, vote: vote

          Decidim::Projects::Admin::PublishVoteCard.call(vote, current_user) do
            on(:ok) do |_vote|
              flash[:notice] = 'Zatwierdzono głos'
              redirect_to votes_cards_path
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zatwierdzić głosu.'
              render :edit
            end
          end
        end

        def status
          enforce_permission_to :status_change, :votes, vote: vote
          @form = form(Decidim::Projects::Admin::ChangeVoteStatusForm).from_model(vote)
        end

        def change_status
          enforce_permission_to :status_change, :votes, vote: vote
          @form = form(Decidim::Projects::Admin::ChangeVoteStatusForm).from_params(params.merge(vote_id: vote.id))

          Decidim::Projects::Admin::UpdateVoteStatus.call(@form, vote, current_user) do
            on(:ok) do |vote|
              flash[:notice] = 'Zaktualizowano status karty do głosowania'
              redirect_to votes_card_path(vote)
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaktualizować statusu karty do głosowania'
              render :status
            end
          end
        end

        # Export all vote_cards to Excel
        def export
          enforce_permission_to :export, :votes

          @votes = filtered_collection.except(:limit, :offset).order(:id)

          # Logging action needs to have resource - for show/list its first/any item
          create_log(@votes.first, :export_votes_to_csv_xlsx) if @votes.any?

          respond_to do |format|
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=Karty-do-glosowania-#{edition_year}_#{I18n.l(Time.current, format: "%d-%m-%Y_%H-%M")}.xlsx"
            end
          end
        end

        # Export all anonymous vote_cards to Excel
        def export_anonymous
          enforce_permission_to :export, :votes

          @votes = filtered_collection.except(:limit, :offset).order(:id)

          # Logging action needs to have resource - for show/list its first/any item
          create_log(@votes.first, :export_votes_to_csv_xlsx) if @votes.any?

          respond_to do |format|
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=Karty-do-glosowania-#{edition_year}_#{I18n.l(Time.current, format: "%d-%m-%Y_%H-%M")}.xlsx"
            end
          end
        end

        # Exports only vote_cards for verification to Excel
        def export_for_verification
          enforce_permission_to :export_for_verification, :votes

          @votes = collection.for_verification

          # Logging action needs to have resource - for show/list its first/any item
          create_log(@votes.first, :export_votes_for_verification) if @votes.any?

          respond_to do |format|
            format.xlsx do
              edition_year = current_component.process.edition_year
              response.headers['Content-Disposition'] = "attachment; filename=Karty-do-weryfikacji-#{edition_year}.xlsx"
            end
          end
        end

        # Admin verify all votes with users lest
        def verify
          enforce_permission_to :verify, :votes
          # Logging action needs to have resource - for show/list its first/any item
          create_log(collection.first, :verify_votes) if collection.any?

          Decidim::Projects::Admin::VerifyVotes.call(current_component) do
            on(:ok) do |_vote|
              flash[:notice] = 'Zweryfikowano karty do głosowania'
              redirect_to votes_cards_path
            end

            on(:no_voters) do
              flash[:alert] = 'Brak zaimportowanej bazy głosujących.'
              redirect_to votes_cards_path
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało się zweryfikować kart do głosowania.'
              redirect_to votes_cards_path
            end
          end
        end

        def resend_email
          enforce_permission_to :resend_email_vote, :votes, vote: vote

          Decidim::Projects::Admin::ResendVoteLink.call(vote, current_user) do
            on(:ok) do |_vote|
              flash[:notice] = 'Mail został wysłany pomyślnie'
              redirect_to votes_cards_path
            end

            on(:email_invalid) do
              flash[:alert] = 'Nie udało się wysłać maila - email odbiorcy jest niepoprawny'
              redirect_to votes_cards_path
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało się wysłać maila'
              redirect_to votes_cards_path
            end
          end
        end

        def resend_all_voting_emails
          enforce_permission_to :resend_all_email_votes, :votes

          Decidim::Projects::Admin::ResendToAllVoteLink.call(votes_with_waiting_status, current_user) do
            on(:ok) do |_vote|
              flash[:notice] = 'Wiadomości zostały wysłane pomyślnie'
              redirect_to votes_cards_path
            end

            on(:empty_votes) do
              flash[:warning] = 'Brak osob spelniajacych kryteria do wysyłki wiadmości'
              redirect_to votes_cards_path
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało się wysłać maila'
              redirect_to votes_cards_path
            end
          end
        end

        def get_voting_link
          enforce_permission_to :get_link_for_vote, :votes, vote: vote

          create_log(vote, :get_link_for_vote)
          voting_link = Decidim::EngineRouter.main_proxy(vote.component).edit_votes_card_url(
            vote,
            token: vote.voting_token,
            link_sent: true,
            host: vote.organization.host
          )
          render json: { link: voting_link }
        end

        private

        def vote_params
          @_params ||= request.parameters
        end

        def for_project
          @project ||= Decidim::Projects::Project.find_by id: params[:project_id]
        end

        def collection
          @collection ||= if for_project
                            Decidim::Projects::UserVoteCards.for(current_user, current_component, for_project).includes(:scope)
                          else
                            Decidim::Projects::UserVoteCards.for(current_user, current_component).includes(:scope)
                          end
        end

        def votes_with_waiting_status
          VoteCard.where(component: current_component).with_active_link
        end

        # Private: filters collection of Votes
        def votes
          @votes ||= filtered_collection
        end

        # Private: retrieves Vote from DB
        def vote
          @vote ||= collection.find_by(voting_token: params[:id]) || collection.find_by(id: params[:id])
        end

        def vote_card_validity
          @vote_card_validity ||= Decidim::Projects::VoteCardValidityService.new(vote)
        end

        def create_log(resource, log_type)
          Decidim::ActionLogger.log(
            log_type,
            current_user,
            resource,
            nil,
            { visibility: 'admin-only' }
          )
        end
      end
    end
  end
end
