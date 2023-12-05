# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows managing all project
  class ProjectsWizardController < Decidim::Projects::ApplicationController
    helper Decidim::Projects::ApplicationHelper
    helper Decidim::Messaging::ConversationHelper
    helper Decidim::WidgetUrlsHelper
    helper Decidim::Projects::ProjectWizardHelper # from proosals
    include Decidim::ApplicationHelper
    include Decidim::Flaggable
    include Decidim::Withdrawable
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Proposals::Orderable # from proosals
    include Decidim::Paginable
    include Decidim::NeedsPermission
    include Decidim::ResourceVersionsConcern
    include Decidim::Projects::ProjectsWithWizard
    helper Decidim::Projects::VoteWizardHelper

    helper_method :project_presenter, :form_presenter, :project, :posters

    before_action :authenticate_user!

    invisible_captcha

    def new
      enforce_permission_to :create, :project, component: current_component
      @step = :step_1_draft
      @form = form(Decidim::Projects::ProjectWizardCreateStepForm).from_params(body: '', additional_data: {})
      @form.universal_design = true # domyslna wartosc dla projektowania uniwersalnego
    end

    def create
      enforce_permission_to :create, :project, component: current_component
      @step = :step_1_draft

      @form = if subaction_for?('draft')
                form(Decidim::Projects::ProjectWizardCreateStepForm).from_params(project_creation_params)
              else
                form(Decidim::Projects::ProjectWizardFirstStepWithValidationForm).from_params(project_creation_params)
              end

      Decidim::Projects::CreateProject.call(@form, current_user) do
        on(:ok) do |project|
          if subaction_for?('draft')
            flash[:notice] = I18n.t('update_draft.success', scope: 'decidim.projects')
            redirect_to edit_draft_projects_wizard_path(project)
          else
            flash[:notice] = I18n.t('create.success', scope: 'decidim.projects')
            redirect_to author_projects_wizard_path(project)
          end
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t('create.error', scope: 'decidim.projects')
          render :new
        end
      end
    end

    # Edit project's author data
    def author
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :edit, :project, project: project
      redirect_to(Decidim::ResourceLocatorPresenter.new(project).path, alert: 'Nie można edytować projektu') and return if project && !project.draft?

      @step = :step_2_author
      @form = form(ProjectWizardAuthorStepForm).from_model(project)
    end

    # Preview projects before publishing
    def preview
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :edit, :project, project: project
      redirect_to(Decidim::ResourceLocatorPresenter.new(project).path, alert: 'Nie można edytować projektu') and return if project && !project.draft?

      @step = :step_3_preview
      @form = form_project_publish_model
      @form.attachment = form_attachment_new
      flash.now[:notice] = I18n.t('update_draft.success', scope: 'decidim.projects')
    end

    # Confirmation for published project
    def confirmation
      project
      @step = :step_4_confirmation
    end

    def edit_draft
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :edit, :project, project: project
      edit_form

      @step = :step_1_draft
      render :edit_draft
    end

    # Update project's author data
    def update_author_data
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :edit, :project, project: project

      @step = :step_2_author
      @form = if subaction_for?('draft')
                form(ProjectWizardAuthorStepForm)
                  .from_params(project_wizard_author_step_params.merge({ project_id: project.id }))
              else
                form(ProjectWizardAuthorStepWithValidationsForm)
                  .from_params(project_wizard_author_step_params.merge({ project_id: project.id }))
              end

      Decidim::Projects::UpdateProject.call(@form, current_user, project) do
        on(:ok) do |project|
          flash[:notice] = I18n.t('update_draft.success', scope: 'decidim.projects')
          redirect_to subaction_for?('draft') ? author_projects_wizard_path(project) : preview_projects_wizard_path(project)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("projects.update_draft.error", scope: "decidim")
          render :author
        end
      end
    end

    def update_draft
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :edit, :project, project: project

      @step = :step_1_draft

      @form = if current_step?('step_1_draft') && subaction_for?('draft')
                form_project_params
              elsif current_step?('step_2_author')
                if subaction_for?('draft')
                  form(ProjectWizardAuthorStepForm)
                    .from_params(project_wizard_author_step_params.merge({ project_id: project.id }))
                else
                  form(ProjectWizardAuthorStepWithValidationsForm)
                    .from_params(project_wizard_author_step_params.merge({ project_id: project.id }))
                end
              else
                form(ProjectWizardFirstStepWithValidationForm)
                  .from_params(project_creation_params.merge({ project_id: project.id }))
              end

      Decidim::Projects::UpdateProject.call(@form, current_user, project) do
        on(:ok) do |project|
          flash[:notice] = I18n.t('update_draft.success', scope: 'decidim.projects')

          redirect_action = if subaction_for?('draft')
                              # when we want to stay on the current step
                              current_step?('step_2_author') ? 'author' : 'edit_draft'
                            else
                              # when we want to go to the next step
                              current_step?('step_2_author') ? 'preview' : 'author'
                            end
          redirect_to action: redirect_action
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("update_draft.error", scope: "decidim.projects")
          if current_step?('step_2_author')
            @step = :step_2_author
            render :author
          else
            @step = :step_1_draft
            render :edit_draft
          end
        end
      end
    end

    def publish
      redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się, by móc wykonać tę czynność') and return unless current_user
      enforce_permission_to :publish, :project, project: project
      redirect_to(Decidim::ResourceLocatorPresenter.new(project).path, alert: 'Nie można edytować projektu') and return if project && !project.draft?

      @form = form_project_publish_model

      Decidim::Projects::PublishProject.call(project, @form, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("projects.publish.success", scope: "decidim")
          redirect_to confirmation_projects_wizard_path(project)
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("projects.publish.error", scope: "decidim")
          if !first_step_errors?(@form)
            wizard_init(:step_1_draft)
            render :edit_draft
          else
            wizard_init(:step_2_author)
            render :author
          end
        end
      end
    end

    # editing already published project
    def edit
      enforce_permission_to :edit, :project, project: project
      edit_form
      wizard_init(:step_1_draft)
    end

    # updating already published project
    def update
      enforce_permission_to :edit, :project, project: project

      @form = project.draft? ? form_project_params : form_project_publish_params

      UpdateProject.call(@form, current_user, project) do
        on(:ok) do |project|
          flash[:notice] = I18n.t("projects.update.success", scope: "decidim")
          redirect_to Decidim::ResourceLocatorPresenter.new(project).path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("projects.update.error", scope: "decidim")
          wizard_init(:step_1_draft)
          render :edit
        end
      end
    end

    def withdraw
      enforce_permission_to :withdraw, :project, project: project

      WithdrawProject.call(project, current_user) do
        on(:ok) do
          flash[:notice] = I18n.t("projects.withdraw.success", scope: "decidim")
          redirect_to decidim_core_extended.account_projects_path
        end

        on(:error) do
          flash[:alert] = I18n.t("projects.withdraw.error", scope: "decidim")
          redirect_to Decidim::ResourceLocatorPresenter.new(project).path
        end
      end
    end

    private

    def project
      @project ||= begin
                     proj = Decidim::Projects::Project.published.not_hidden.find_by(id: params[:id])
                     proj = Decidim::Projects::Project.from_author(current_user).find_by(id: params[:id]) if !proj && current_user
                     proj
                   end
    end

    def project_presenter
      @project_presenter ||= present(project)
    end

    def form_presenter
      @form_presenter ||= present(@form, presenter_class: Decidim::Projects::ProjectPresenter)
    end

    def form_project_params
      form(Decidim::Projects::ProjectWizardCreateStepForm).from_params(params)
    end

    def form_project_model
      form(Decidim::Projects::ProjectWizardCreateStepForm).from_model(project)
    end

    def form_project_publish_model
      form(Decidim::Projects::ProjectForm).from_model(project)
    end

    def form_project_publish_params
      form(Decidim::Projects::ProjectForm).from_params(params.merge({ project_id: project.id }))
    end

    def form_attachment_new
      form(Decidim::AttachmentForm).from_model(Decidim::Attachment.new)
    end

    # przy publikacji moze byc cofniecie do edycji autora, wtedy jest params[:project]
    def project_wizard_author_step_params
      params[:project_wizard_author_step].presence || params[:project]
    end

    def edit_form
      form_attachment_model = form(Decidim::AttachmentForm).from_model(project.attachments.first)
      @form = project.draft? ? form_project_model : form_project_publish_model
      @form.attachment = form_attachment_model
      @form
    end

    def first_step_errors?(project)
      [:title, :short_description, :body, :universal_design, :universal_design_argumentation, :justification_info,
       :budget_value, :add_photos, :add_documents, :add_more_documents].each do |attr|
        return true if project.errors[attr.to_s].present?
      end
      false
    end

    def permission_scope
      :public
    end

    def permission_class_chain
      [
        current_component.manifest.permissions_class,
        current_participatory_space.manifest.permissions_class,
        Decidim::Permissions
      ]
    end

    def user_has_no_permission_path
      '/projects'
    end

    def project_creation_params
      params[:project]
    end

    def generate_map_markers(project, vote = nil, step = nil)
      cell("decidim/meetings/content_blocks/upcoming_events", nil).generate_map_markers_for_single_project(project, true, vote, step).html_safe
    end

    def current_step?(step)
      params[:step] && params[:step] == step
    end

    def posters
      @posters ||= Decidim::Projects::PosterTemplate.where(process: project.participatory_space).published
    end

    def handle_action_while_voting
      return unless params[:voting].present?
      return unless current_participatory_space.active_step == current_participatory_space.voting_step

      wizard_step_for_project = project.is_district_project? ? Decidim::Projects::VotingWizard::STEPS::DISTRICT_LIST : Decidim::Projects::VotingWizard::STEPS::GLOBAL_SCOPE_LIST
      @wizard ||= Decidim::Projects::VotingWizard.new(current_component, wizard_step_for_project)

      @vote_card = Decidim::Projects::VoteCard.where(decidim_component_id: current_component.id)
                                              .find_by(voting_token: params[:voting])
      if @vote_card && @vote_card.last_active_statistic
        @vote_card.last_active_statistic.increment!(:district_projects_views_count) if project.is_district_project?
        @vote_card.last_active_statistic.increment!(:global_projects_views_count) if project.is_global_project?
      end
    end
  end
end
