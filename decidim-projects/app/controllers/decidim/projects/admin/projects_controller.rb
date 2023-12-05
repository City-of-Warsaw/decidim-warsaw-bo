# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing projects in admin panel.
      class ProjectsController < Admin::ApplicationController
        include Decidim::ApplicationHelper
        include Decidim::Projects::Admin::Filterable
        include Decidim::Projects::Admin::ProjectsExport
        include Decidim::Projects::Admin::ProjectsFilteredCollection

        helper_method :projects, :query, :form_presenter, :project, :project_ids, :search_params_for_export, :admin_filter_selector
        helper Projects::Admin::ProjectBulkActionsHelper
        helper Decidim::Projects::CoauthorsHelper

        def index
          @projects = filtered_collection_projects
          @all_projects_count = @projects.count
          @projects = paginate(@projects)
        end

        def show
          enforce_permission_to :show, :project, project: project
          create_log(project, :show)

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

        def new
          enforce_permission_to :create, :project, component: current_component
          @form = form(Decidim::Projects::Admin::ProjectForm).from_params(
            is_paper: true,
            evaluator: current_user,
            state: 'admin_draft',
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          enforce_permission_to :create, :project, component: current_component
          @form = form(Decidim::Projects::Admin::ProjectForm).from_params(params)

          Admin::CreateProject.call(@form) do
            on(:ok) do |project|
              flash[:notice] = I18n.t('projects.create.success', scope: 'decidim.projects.admin')
              redirect_to project_path(project)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t('projects.create.invalid', scope: 'decidim.projects.admin')
              render action: 'new'
            end
          end
        end

        def edit
          enforce_permission_to :edit, :project, project: project
          create_log(project, :edit)
          @form = if (current_user.ad_admin? || current_user.ad_coordinator?) && project.admin_changes.present?
                    form(Admin::ChangesProjectForm).from_model(project)
                  else
                    form(Admin::ProjectForm).from_model(project)
                  end
        end

        def update
          enforce_permission_to :edit, :project, project: project

          @form = form(Admin::ProjectForm).from_params(params)
          if subaction_for?('accept')
            Decidim::Projects::Admin::AcceptChanges.call(project.component, current_user, [project.id]) do
              on(:invalid) do
                flash.now[:alert] = 'Nie udało sie zatwierdzić zmian w projekcie.'
                render :edit
              end

              on(:ok) do |project|
                flash[:notice] = 'Zatwierdzono zmiany w projekcie.'
                redirect_to project_path(project)
              end
            end
          else
            Admin::UpdateProject.call(@form, @project, params[:subaction]) do
              on(:ok) do |_project|
                flash[:notice] = t('projects.update.success', scope: 'decidim')
                redirect_to project_path(_project)
              end

              on(:invalid) do
                flash.now[:alert] = t('projects.update.error', scope: 'decidim')
                render :edit
              end
            end
          end
        end

        def status
          enforce_permission_to :status_change, :project, project: project
          @form = form(Decidim::Projects::Admin::ChangeStatusForm).from_model(project)
        end

        def change_status
          enforce_permission_to :status_change, :project, project: project
          @form = form(Decidim::Projects::Admin::ChangeStatusForm).from_params(params.merge(project_id: project.id))

          Admin::UpdateProjectStatus.call(@form, project) do
            on(:ok) do |_project|
              flash[:notice] = 'Zaktualizowano status projektu'
              redirect_to projects_path
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaktualizować statusu projektu'
              render :status
            end
            on(:invalid_budget_value) do
              flash.now[:alert] = 'Projekt musi mieć ustawioną wartość budżetu aby poprawnie zaktualizować status projektu'
              render :status
            end
          end
        end



        def accept_changes
          enforce_permission_to :bulk_action, :project

          Decidim::Projects::Admin::AcceptChanges.call(current_component, current_user, project_ids) do
            on(:invalid) do
              flash.now[:alert] = 'Zaden z wybranych projektów nie miał zmian do zatwierdzenia.'
            end

            on(:ok) do
              flash.now[:notice] = 'Zatwierdzono zmiany w projektach.'
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def accept_evaluations
          enforce_permission_to :bulk_action, :project

          Decidim::Projects::Admin::AcceptEvaluations.call(current_component, current_user, project_ids) do
            on(:invalid) do
              flash.now[:alert] = 'Zaden z wybranych projektów nie miał oceny do zatwierdzenia.'
            end

            on(:ok) do
              flash.now[:notice] = 'Zatwierdzono oceny projektów.'
            end
          end

          respond_to do |format|
            format.js
          end
        end

        # Sends bulk messages to projects authors
        def send_messages
          enforce_permission_to :bulk_message_send, :project, component: current_component

          Decidim::Projects::Admin::SendMessages.call(current_component, current_user, project_ids, params[:body]) do
            on(:ok) do
              flash.now[:notice] = 'Wysłano wiadomość do autorów wybranych projektów.'
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się wysłać wiadomości do żadnego z autorów.'
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def new_message
          enforce_permission_to :send_message, :project, project: project
          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'project_status_changed_author_info_email_template')
          params[:body] = mail_template.body if mail_template && mail_template.body.present?
        end

        def send_message
          enforce_permission_to :send_message, :project, project: project

          Decidim::Projects::Admin::SendMessages.call(current_component, current_user, [project.id], params[:body]) do
            on(:ok) do
              flash[:notice] = 'Wysłano wiadomość do autorów projektu.'
              redirect_to projects_path
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się wysłać wiadomości do autorów projektu.'
              render :new_message
            end
          end
        end

        def accept_coautorship
          enforce_permission_to :coauthor_accept, :project, project: project

          coauthorship = project.coauthorships.for_acceptance.for_decidim_users.find_by(decidim_author_id: params[:user_id])
          if coauthorship.nil?
            flash.now[:alert] = 'Nie udało sie potwierdzić współautorstwa'
            redirect_to project_path(project)
          end

          AcceptCoauthorship.call(coauthorship, current_user) do
            on(:ok) do
              flash[:notice] = 'Współautorstwo zostało potwierdzone, a użytkownik otrzymał powiadomienie email.'
              redirect_to project_path(project)
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało sie potwierdzić współautorstwa'
              redirect_to project_path(project)
            end
          end
        end

        def assign_to_valuator
          enforce_permission_to :bulk_subcoordinator_action, :project

          Decidim::Projects::Admin::AssignEvaluatorToProjects.call(current_component, current_user, project_ids, params[:valuator]) do
            on(:ok) do |assigned|
              unless assigned[:assigned].nil?
                flash.now[:notice] = "Przypisano projekty #{assigned[:assigned].join(",")} do weryfikatora."
              end
              unless assigned[:not_assigned].nil?
                flash.now[:error] = "Projekty niezmienione - #{assigned[not_assigned].join(",")}."
              end
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def forward_to_department
          enforce_permission_to :bulk_action, :project

          department = Decidim::AdminExtended::Department.find_by(id: params[:department][:id]) if params[:department]

          Decidim::Projects::Admin::ForwardProjectsToDepartment.call(current_component, current_user, project_ids, department) do
            on(:invalid) do
              flash.now[:alert] = 'Zaden z wybranych projektów nie mógł zostać przekazany do wybranej komórki.'
            end

            on(:ok) do
              flash.now[:notice] = 'Przekazano projekty do komórki.'
            end
          end

          respond_to do |format|
            format.js
          end
        end

        def remind_about_drafts
          enforce_permission_to :remind_about_drafts, :projects, component: current_component
          Decidim::Projects::RemindAboutDraftProjectsJob.perform_later
          redirect_to projects_path, notice: 'Rozpoczęto wysyłanie przypomnienia do autorów o kopiach roboczych.'
        end

        def notify_authors_about_evaluation_result
          enforce_permission_to :notify_authors_about_evaluation_result, :projects, component: current_component, project: project

          Decidim::Projects::NotifyAuthorsAboutEvaluationResultsJob.perform_later(current_component, current_user, project)
          redirect_to project_path(project), notice: 'Rozpoczęto wysyłanie powiadomienia do autorów projektu o publikacji wyników oceny'
        end

        def notify_authors_about_evaluation_results
          enforce_permission_to :notify_authors_about_evaluation_results, :projects, component: current_component

          Decidim::Projects::NotifyAuthorsAboutEvaluationResultsJob.perform_later(current_component, current_user)
          redirect_to projects_path, notice: 'Rozpoczęto wysyłanie powiadomienia do autorów projektów o publikacji wyników oceny'
        end

        def notify_authors_about_all_evaluation_results
          enforce_permission_to :notify_authors_about_all_evaluation_results, :projects, component: current_component

          Decidim::Projects::NotifyAuthorsAboutEvaluationResultsJob.perform_later(current_component, current_user, nil, for_all_projects = true)
          redirect_to projects_path, notice: 'Rozpoczęto wysyłanie powiadomienia do autorów wszystkich projektów o publikacji wyników oceny'
        end

        # Before the end evaluation step,
        # the system sends a notification to the coordinator with information about deficiencies in the evaluation of individual projects.
        def remind_about_missing_evaluations
          enforce_permission_to :remind_about_missing_evaluations, :projects, component: current_component
          Decidim::Projects::RemindAboutMissingEvaluationsProjectsJob.perform_later
          redirect_to projects_path, notice: 'Rozpoczęto wysyłanie przypomnienia do koordynatorów o brakach w ocenie.'
        end

        # Mark projects with conflicts in edition - on the same location
        def mark_conflicts
          enforce_permission_to :mark_conflicts, :project
          Decidim::Projects::Admin::MarkConflictedProjects.call(current_component, current_user) do
            on(:ok) do
              flash[:notice] = 'Oznaczono projekty będące w konflikcie lokalizacji.'
            end
          end

          redirect_to projects_path
        end

        def erase_user_data
          enforce_permission_to :erase_user_data, :projects, component: current_component
          Decidim::Projects::Admin::EraseUserData.call(collection, current_user) do
            on(:ok) do
              flash[:notice] = 'Dane użytkowników zostały wyczyszczone'
            end
          end

          redirect_to projects_path
        end

        def register_to_signum
          enforce_permission_to :register_to_signum, :project, project: project

          Decidim::Projects::Admin::RegisterToSignum.call(current_component, current_user, project) do
            on(:registered_already) do
              flash[:alert] = 'Ten projekt już jest zarejestrowany w Signum.'
            end

            on(:invalid_login) do
              flash[:alert] = "Projekt nie został zarejestrowany z powodu braku konta '#{current_user.ad_name}' w Signum"
            end

            on(:ok) do
              flash[:notice] = 'Zarejestrowano projekt w Signum'
            end
          end
          redirect_to project_path(project)
        end

        def register_all_to_signum
          Decidim::Projects::Admin::RegisterAllToSignum.call(current_component, current_user, project_ids) do
            on(:invalid_login) do
              flash.now[:alert] = "Projekty nie zostaną zarejestrowane z powodu braku konta '#{current_user.ad_name}' w Signum"
            end

            on(:invalid) do
              flash.now[:alert] = 'Żaden z wybranych projektów nie został zarejestrowany.'
            end

            on(:ok) do
              flash.now[:notice] = 'Rozpoczęto rejestrację projektów w Signum. Odśwież stronę, żeby zobaczyć numery Signum.'
            end
          end

          respond_to do |format|
            format.js
          end
        end

        private

        def filtered_collection_projects
          @form = form(Decidim::Projects::Admin::ProjectsFilterForm).from_params(params)
          if @form.invalid?
            flash[:alert] = 'Formularz zawiera niepoprawne pola'
            redirect_to projects_path
          end
          Decidim::AdminExtended::FilteredProjects.new(collection, @form).call
        end

        def collection
          @collection ||= collection_filtered_by_user_permission
        end

        def projects
          @projects ||= filtered_collection
        end

        def project
          @project ||= collection.find_by(id: params[:id])
        end

        def participatory_process
          @participatory_process ||= Decidim::ParticipatoryProcess.find_by(slug: params[:participatory_process_slug])
        end

        def project_ids
          @project_ids ||= params[:project_ids]
        end

        def form_presenter
          @form_presenter ||= present(@form, presenter_class: Decidim::Projects::ProjectPresenter)
        end

        def admin_filter_selector(i18n_ctx = nil)
          render partial: 'decidim/projects/admin/projects/filters', locals: { i18n_ctx: i18n_ctx }
        end

        # filter allowed params for export, used in links
        def search_params_for_export
          return unless params[:q]

          params[:q].permit(:categories_id_in, :is_paper_eq, :recipients_id_in, :scope_id_eq, :scope_scope_type_id_eq, :state_eq)
        end
      end
    end
  end
end
