# frozen_string_literal: true

module Decidim
  module CoreExtended
    module Account
      class AppealsController < Decidim::CoreExtended::ApplicationController
        include Decidim::UserProfile
        helper Decidim::ResourceHelper
        layout 'decidim/core_extended/user_profile'

        helper_method :latest_edition_projects, :latest_edition, :appeals, :appeal

        def index; end

        def new
          redirect_to([:account, :appeals], alert: 'Nie można składać jeszcze odwołań.') and return unless latest_edition.time_for_appeals?

          if params[:project_id].present?
            @project = current_user.projects.find_by(id: params[:project_id])
            redirect_to([:new, :account, appeal], alert: 'Nie znaleziono projektu.') and return unless @project
            redirect_to([:edit, :account, @project.appeal], notice: 'Masz już zapisaną kopię roboczą odwołania') and return if @project.appeal

            @form = form(Decidim::CoreExtended::AppealForm).from_params({ project_id: params[:project_id] })
          else
            @form = form(Decidim::CoreExtended::AppealForm).instance
          end
        end

        def create
          @form = form(Decidim::Projects::AppealForm).from_params(params[:appeal])
          @project = @form.project

          redirect_to([:new, :account, appeal], alert: 'Nie znaleziono projektu.') and return unless @project
          redirect_to([:edit, :account, @project.appeal], notice: 'Masz już zapisaną kopię roboczą odwołania') and return if @project.appeal

          Decidim::Projects::CreateAppeal.call(@form, current_user) do
            on(:ok) do |appeal|
              if subaction_for?('publish')
                Decidim::Projects::PublishAppeal.call(@form, appeal, current_user, true) do
                  on(:ok) do |appeal|
                    flash[:notice] = I18n.t("appeals.publish.success", scope: "decidim")
                    redirect_to([:account, appeal])
                  end

                  on(:invalid) do
                    flash[:alert] = I18n.t("appeals.publish.error", scope: "decidim")
                    redirect_to([:edit, :account, appeal])
                  end
                end
              else
                flash[:notice] = I18n.t("appeals.create.success", scope: "decidim")
                redirect_to [:account, appeal]
              end
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("appeals.create.error", scope: "decidim")
              render :new
            end
          end
        end

        def show
          redirect_to(account_appeals_path, alert: 'Nie znaleziono odwołania.') and return unless appeal
        end

        def edit
          redirect_to(account_appeals_path, alert: 'Nie znaleziono odwołania.') and return unless appeal
          redirect_to(account_appeal_path(appeal), alert: 'Odwołanie zostało już złożone.') and return if appeal.submitted?

          @form = form(Decidim::Projects::AppealForm).from_model(appeal)
        end

        def update
          redirect_to(account_appeals_path, alert: 'Nie znaleziono odwołania.') and return unless appeal

          @form = form(Decidim::Projects::AppealForm).from_params(params[:appeal].merge(project_id: appeal.project_id))

          Decidim::Projects::UpdateAppeal.call(@form, current_user, @appeal) do
            on(:ok) do |appeal|
              if subaction_for?('publish')
                Decidim::Projects::PublishAppeal.call(@form, @appeal, current_user, true) do
                  on(:ok) do |appeal|
                    flash[:notice] = I18n.t("appeals.publish.success", scope: "decidim")
                    redirect_to([:account, appeal])
                  end
                  on(:invalid) do
                    flash.now[:alert] = I18n.t("appeals.publish.error", scope: "decidim")
                    render :edit
                  end
                end
              else
                flash[:notice] = I18n.t("appeals.update.success", scope: "decidim")
                redirect_to([:account, appeal])
              end
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("appeals.update.error", scope: "decidim")
              render :edit
            end
          end
        end

        def destroy
          redirect_to(account_appeals_path, alert: 'Nie znaleziono odwołania.') and return unless appeal

          if appeal.time_of_submit.nil?
            appeal.destroy
            flash[:notice] = I18n.t("appeals.destroy.success", scope: "decidim")
          else
            flash[:alert] = I18n.t("appeals.destroy.error", scope: "decidim")
          end
          redirect_to([:account, :appeals])
        end

        private

        def appeals
          @appeals ||= Decidim::Projects::Appeal
                         .joins(:project)
                         .where('decidim_projects_projects.id': current_user.authored_projects.pluck(:id))
        end

        def appeal
          @appeal ||= appeals.find_by(id: params[:id])
        end

        def latest_edition_projects
          @latest_edition_authored_projects ||= current_user.authored_projects
                                                            .waiting_for_appeal
                                                            .joins(:component)
                                                            .where('decidim_components.participatory_space_id': latest_edition.id)
        end

        def latest_edition
          @latest_edition ||= Current.actual_edition
        end
      end
    end
  end
end
