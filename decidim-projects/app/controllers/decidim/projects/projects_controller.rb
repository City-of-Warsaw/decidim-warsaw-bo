# frozen_string_literal: true

module Decidim::Projects
  # Controller that allows managing all project
  class ProjectsController < Decidim::Projects::ApplicationController
    helper Decidim::Projects::ApplicationHelper
    helper Decidim::Messaging::ConversationHelper
    helper Decidim::WidgetUrlsHelper
    helper Decidim::Projects::ProjectWizardHelper # from proposals
    include Decidim::ApplicationHelper
    include Decidim::Flaggable
    include Decidim::Withdrawable
    include Decidim::FormFactory
    include Decidim::FilterResource
    include Decidim::Proposals::Orderable # from proposals
    include Decidim::Paginable
    include Decidim::NeedsPermission
    include Decidim::ResourceVersionsConcern
    helper Decidim::Projects::VoteWizardHelper
    helper Decidim::Projects::CoauthorsHelper

    helper_method :project_presenter, :form_presenter, :project, :posters

    before_action :authenticate_user!, only: [:new, :create, :preview]

    invisible_captcha

    def index
      @base_query = search
                    .results
                    .published
                    .not_hidden
                    .order(id: :asc)

      # For TESTS only
      # @base_query = Rails.env.production? ? @base_query.where(id: [25701, 25700, 25698]) : @base_query.where(id: [8604, 8611, 8607])

      @projects = @base_query.includes(:component, :coauthorships)
      @all_geocoded_projects = @base_query.geocoded

      @projects = paginate(@projects)
    end

    def show
      enforce_permission_to :show, :project, project: project

      redirect_to(projects_path, alert: 'Nie znaleziono proejktu.') and return unless project

      vote_card = params[:voting] ? Decidim::Projects::VoteCard.where(decidim_component_id: current_component.id).find_by(voting_token: params[:voting]) : nil
      @all_locations = generate_map_markers(project, vote_card, params[:step])
      @private_message_form = form(Decidim::Projects::PrivateMessageForm).from_params(body: '', project_id: project.id, email: current_user&.email)
      handle_action_while_voting

      respond_to do |format|
        format.html
        format.pdf do
          render pdf: "Projekt-#{project.id}",
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

    # return project details info for popup on map
    def map_details_data
      @vote_card = Decidim::Projects::VoteCard.find_by(voting_token: params[:vote]) if params[:vote].present?
      @step = params[:step] if params[:step].present?

      render partial: 'map_details_data', locals: { project: project, vote: @vote_card, step: @step }
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

    def edit_form
      form_attachment_model = form(Decidim::AttachmentForm).from_model(project.attachments.first)
      @form = project.draft? ? form_project_model : form_project_publish_model
      @form.attachment = form_attachment_model
      @form
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
