# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows managing appeals to user negatively verified projects in admin panel
  class Admin::AppealsController < Admin::ApplicationController
    include Decidim::Paginable
    include Decidim::Projects::Admin::AppealsFilterable

    helper Decidim::Projects::Admin::ProjectsHelper
    helper_method :collection, :appeals, :query


    def index
      enforce_permission_to :show, :appeal

      @appeals = appeals.result
      @appeals = paginate(@appeals)
    end

    def show
      @appeal = Decidim::Projects::Appeal.find(params[:id])
      enforce_permission_to :show, :appeal

      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Odwołanie-#{@appeal.project.esog_number}", disposition: 'attachment'
        end
      end
    end

    def new
      enforce_permission_to :create, :appeal
      @form = form(Decidim::Projects::Admin::AppealForm).from_params(attachment: form(Decidim::AttachmentForm).from_params({}))
    end

    def create
      enforce_permission_to :create, :appeal
      @form = form(Decidim::Projects::Admin::AppealForm).from_params(params[:appeal])

      Decidim::Projects::Admin::CreateAppeal.call(@form, current_user) do
        on(:ok) do |appeal|
          success_msg = appeal.project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_DRAFT ? 'success_reminder' : 'success'
          flash[:notice] = I18n.t(success_msg, scope: "decidim.projects.admin.appeals.create")
          redirect_to appeals_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("appeals.create.error", scope: "decidim.projects.admin")
          render action: "new"
        end
      end
    end

    def edit
      @appeal = Decidim::Projects::Appeal.find(params[:id])
      enforce_permission_to :edit, :appeal, appeal: @appeal
      @form = form(Decidim::Projects::Admin::AppealForm).from_model(@appeal)
    end

    def update
      @appeal = Decidim::Projects::Appeal.find(params[:id])
      enforce_permission_to :edit, :appeal, appeal: @appeal
      @form = form(Decidim::Projects::Admin::AppealForm).from_params(params[:appeal].merge(appeal: @appeal))

      Decidim::Projects::Admin::UpdateAppeal.call(@form, current_user, @appeal) do
        on(:ok) do |appeal|
          success_msg = appeal.project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_DRAFT ? 'success_reminder' : 'success'
          flash[:notice] = I18n.t(success_msg, scope: "decidim.projects.admin.appeals.update")
          redirect_to appeals_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("appeals.update.error", scope: "decidim.projects.admin")
          render action: "edit"
        end
      end
    end

    private

    def collection
      projects = if current_user.ad_admin?
                   Decidim::Projects::Project.where(component: current_component)
                 elsif current_user.ad_coordinator?
                   Decidim::Projects::Project.where(component: current_component)
                     .where.not(current_department_id: nil)
                     .where(current_department: current_user.department)
                     .or(Decidim::Projects::Project.where(component: current_component)
                           .where.not(decidim_scope_id: nil)
                           .where(decidim_scope_id: current_user.assigned_scope_id)
                     )
                 elsif current_user.ad_editor?
                   Decidim::Projects::Project.none
                 else
                   current_user.assigned_projects
                 end
      projects_ids = projects.pluck(:id).uniq

      @collection ||= Decidim::Projects::Appeal.where('decidim_projects_appeals.author_id': current_user.id)
                                               .or(Decidim::Projects::Appeal.where('decidim_projects_appeals.project_id': projects_ids))
                                               .where('decidim_components.participatory_space_id': current_participatory_space.id)
                                               .joins(project: :component)
                                               .order('decidim_projects_projects.esog_number': :asc)


    end

    def appeals
      @appeals ||= filtered_collection
    end

    # alias collection appeals
  end
end
