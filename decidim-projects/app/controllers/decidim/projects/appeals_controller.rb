# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows managing appeals to user negatively verified projects
  class AppealsController < Decidim::Projects::ApplicationController
    include Decidim::FormFactory

    before_action :find_project, only: [:new, :create]
    before_action :find_appeal, only: [:edit, :update, :publish]

    def show
      @project = Decidim::Projects::Project.published.not_hidden.find_by(id: params[:project_id])
      @appeal = @project.appeal
      enforce_permission_to :read_appeal, :project, project: @project

      @form = form(Decidim::Projects::AppealForm).from_model(@appeal)
    end

    def new
      enforce_permission_to :appeal, :project, project: @project
      @form = form(Decidim::Projects::AppealForm).from_params(project_id: @project.id)
    end

    def create
      enforce_permission_to :appeal, :project, project: @project
      @form = form(Decidim::Projects::AppealForm).from_params(params[:appeal].merge(project_id: @project.id))

      Decidim::Projects::CreateAppeal.call(@form, current_user) do
        on(:ok) do |appeal|
          if subaction_for?('publish')
            Decidim::Projects::PublishAppeal.call(@form, appeal, current_user) do
              on(:ok) do |appeal|
                flash[:notice] = I18n.t("appeals.publish.success", scope: "decidim")
                redirect_to appeal.project
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("appeals.publish.error", scope: "decidim")
                render :edit
              end
            end
          else
            flash[:notice] = I18n.t("appeals.create.success", scope: "decidim")
            redirect_to [appeal.project, appeal]
          end
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("appeals.create.error", scope: "decidim")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :appeal, :project, project: @project
      @form = form(Decidim::Projects::AppealForm).from_model(@appeal)
    end

    def update
      enforce_permission_to :appeal, :project, project: @project
      @form = form(Decidim::Projects::AppealForm).from_params(params[:appeal].merge(project_id: @project.id))

      if subaction_for?('publish')
        Decidim::Projects::PublishAppeal.call(@form, @appeal, current_user) do
          on(:ok) do |appeal|
            flash[:notice] = I18n.t("appeals.publish.success", scope: "decidim")
            redirect_to appeal.project
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("appeals.publish.error", scope: "decidim")
            render :edit
          end
        end
      else
        Decidim::Projects::UpdateAppeal.call(@form, current_user, @appeal) do
          on(:ok) do |appeal|
            flash[:notice] = I18n.t("appeals.update.success", scope: "decidim")
            redirect_to [appeal.project, appeal]
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("appeals.update.error", scope: "decidim")
            render :edit
          end
        end
      end
    end

    # Public: publish appeal
    #
    # Controller action that allows submitting appeal of the project for reevaluation
    def publish
      enforce_permission_to :appeal, :project, project: @project
      @form = form(Decidim::Projects::AppealForm).from_model(@appeal)

      Decidim::Projects::PublishAppeal.call(@form, @appeal, current_user, true) do
        on(:ok) do |appeal|
          flash[:notice] = I18n.t("appeals.publish.success", scope: "decidim")
          redirect_to appeal.project
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("appeals.publish.error", scope: "decidim")
          render :edit
        end
      end
    end

    private

    def find_project
      @project = Decidim::Projects::Project.published.not_hidden.find_by(id: params[:project_id])

      if @project.appeal
        redirect_to([:edit, @project, @project.appeal], notice: 'Masz już zapisaną kopię roboczą odwołania') and return
      end
    end

    def find_appeal
      @appeal = Decidim::Projects::Appeal.find_by(id: params[:id])
      @project = @appeal.project
    rescue
      redirect_to('/projects', alert: 'Nie udało się odnaleźć szukanego zasobu') and return
    end
  end
end
