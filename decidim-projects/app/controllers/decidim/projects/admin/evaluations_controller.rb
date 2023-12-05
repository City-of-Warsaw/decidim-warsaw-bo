# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing evaluations (formal and maritorical) in admin panel.
      class EvaluationsController < Admin::ApplicationController
        include ::Decidim::MultipleAttachmentsMethods

        helper Decidim::TooltipHelper
        helper Projects::Admin::ProjectsHelper

        before_action :find_evaluated_project, only: [:finish_admin_draft, :return_admin_draft,
                                                      :publish_project, :submit_for_formal, :finish_formal, :accept_formal,
                                                      :submit_for_meritorical, :finish_meritorical, :accept_meritorical, :finish_project_verification,
                                                      :choose_department, :choose_verificator, :choose_user,
                                                      :forward_to_department, :add_return_reason, :return_to_department,
                                                      :forward_to_user, :remove_sub_coordinator,
                                                      :choose_new_verificator, :change_verificator, :remove_verificator,
                                                      :add_note_for_verificator, :return_to_verificator]


        def finish_admin_draft
          enforce_permission_to :finish_admin_draft, :project_evaluate, project: @project
          
          Decidim::Projects::Admin::Evaluation::FinishAdminDraft.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Projekt przekazano do koordynatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do koordynatora."
              redirect_to @project
            end
          end
        end

        def return_admin_draft
          enforce_permission_to :return_admin_draft, :project_evaluate, project: @project

          Decidim::Projects::Admin::Evaluation::ReturnAdminDraft.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Projekt przekazano ponownie do edytora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do edytora"
              redirect_to @project
            end
          end
        end

        def publish_project
          enforce_permission_to :publish_project, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::PublishProject.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Projekt został opublikowany"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się opublikować projektu"
              redirect_to @project
            end
          end
        end

        def submit_for_formal
          enforce_permission_to :submit_for_formal, :project_evaluate, project: @project
          evaluator = Decidim::User.find_by(id: params[:choose_verificator][:evaluator_id])
          Decidim::Projects::Admin::Evaluation::SubmitForFormal.call(@project, current_user, evaluator) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do oceny formalnej"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do oceny formalnej"
              redirect_to @project
            end
          end
        end

        def finish_formal
          enforce_permission_to :finish_formal, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::FinishFormal.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Ocena formalna projektu została przekazana do koordynatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać oceny projektu do koordynatora"
              redirect_to @project
            end
          end
        end

        def accept_formal
          enforce_permission_to :accept_formal, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::AcceptFormal.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Ocena formalna projektu została zaakceptowana przez koordynatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się zaakceptować oceny projektu"
              redirect_to @project
            end
          end
        end

        def submit_for_meritorical
          enforce_permission_to :submit_for_meritorical, :project_evaluate, project: @project
          evaluator = Decidim::User.find_by(id: params[:choose_verificator][:evaluator_id])
          Decidim::Projects::Admin::Evaluation::SubmitForMeritorical.call(@project, current_user, evaluator) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do oceny merytorycznej"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do oceny merytorycznej"
              redirect_to @project
            end
          end
        end

        def finish_meritorical
          enforce_permission_to :finish_meritorical, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::FinishMeritorical.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Ocena merytoryczna projektu została przekazana do koordynatora"
              redirect_to @project
            end
            on(:invalid_budget) do
              flash[:alert] = "Wartość budżetu nie może być pusta ani nie może przekraczać limitu."
              redirect_to @project
            end
            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać oceny projektu do koordynatora"
              redirect_to @project
            end
          end
        end

        def accept_meritorical
          enforce_permission_to :accept_meritorical, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::AcceptMeritorical.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Ocena merytoryczna projektu została zaakceptowana przez koordynatora"
              redirect_to @project
            end
            on(:invalid_budget) do
              flash[:alert] = "Wartość budżetu nie może być pusta ani nie może przekraczać limitu."
              redirect_to @project
            end
            on(:invalid) do
              flash[:alert] = "Nie udało się zaakceptować oceny projektu"
              redirect_to @project
            end
          end
        end

        def finish_project_verification
          enforce_permission_to :finish_project_verification, :project_evaluate, project: @project
          Decidim::Projects::Admin::Evaluation::FinishProjectVerification.call(@project, current_user) do
            on(:ok) do
              flash[:notice] = "Zakończono ocenianie projektu. Karty ocen zostaną wygenerowane automatycznie i opublikowane zgodnie z czasem publikacji wyników"
              redirect_to @project
            end
            on(:invalid_budget) do
              flash[:alert] = "Wartość budżetu nie może być pusta ani nie może przekraczać limitu."
              redirect_to @project
            end
            on(:invalid) do
              flash[:alert] = "Nie udało się zakończyc oceniania projektu"
              redirect_to @project
            end
          end
        end

        def choose_department
          enforce_permission_to :forward_to_department, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ChooseDepartmentForm).from_model(@project)
        end

        def forward_to_department
          enforce_permission_to :forward_to_department, :project_evaluate, project: @project
          department = Decidim::AdminExtended::Department.find params[:choose_department][:department_id]

          Decidim::Projects::Admin::Evaluation::ForwardToDepartment.call(@project, current_user, department) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do komórki"
              redirect_to root_path
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do komórki"
              redirect_to @project
            end

            on(:no_ad_name) do
              flash[:alert] = "Komórka nie ma ustawionej Nazwa AD. Sprawdź, czy nie jest komórką historyczną"
              redirect_to @project
            end

            on(:no_coordinators) do
              flash[:alert] = "We wskazanej komórce nie ma koordynatorów, projekt nie mógł zostać do niej przekazany"
              redirect_to @project
            end

            on(:invalid_state) do
              flash[:alert] = "Nie udało się przekazać projektu do komórki, gdyż jest on albo kopią roboczą, albo został wycofany przez autora"
              redirect_to @project
            end
          end
        end

        def add_return_reason
          enforce_permission_to :return_to_department, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ReturnToDepartmentForm).from_model(@project)
        end

        def return_to_department
          enforce_permission_to :return_to_department, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ReturnToDepartmentForm).from_params(params[:evaluation_note].merge(project_id: @project.id))

          Decidim::Projects::Admin::Evaluation::ReturnToDepartment.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = "Zwrócono projekt do poprzedniej komórki"
              redirect_to root_path
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się zwrócić projektu"
              render :add_return_reason
            end

            on(:invalid_state) do
              flash[:alert] = "Nie można zwrócić projektu, gdyż jest on albo kopią roboczą, albo został wycofany przez autora"
              redirect_to @project
            end

            on(:no_previous_department) do
              flash[:alert] = "Nie można zwrócić projektu, nie znaleziono poprzedniej komórki"
              redirect_to @project
            end
          end
        end

        def choose_verificator
          enforce_permission_to :submit_for_verification, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ChooseVerificatorForm).from_model(@project)
        end

        def choose_new_verificator
          enforce_permission_to :change_verificator, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ChooseVerificatorForm).from_model(@project)
        end

        def change_verificator
          enforce_permission_to :change_verificator, :project_evaluate, project: @project
          user = Decidim::User.find_by(id: params[:choose_verificator][:evaluator_id])

          Decidim::Projects::Admin::Evaluation::ChangeVerificator.call(@project, current_user, user) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do nowego weryfikatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się zmienić przypisania do weryfikatora"
              redirect_to @project
            end
          end
        end

        def remove_verificator
          enforce_permission_to :change_verificator, :project_evaluate, project: @project

          Decidim::Projects::Admin::Evaluation::ChangeVerificator.call(@project, current_user, nil) do
            on(:ok) do
              flash[:notice] = "Projekt został odebrany weryfikatorowi"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się zmienić przypisania do weryfikatora"
              redirect_to @project
            end
          end
        end

        def choose_user
          enforce_permission_to :forward_to_user, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::ChooseUserForm).from_model(@project)
        end

        def forward_to_user
          enforce_permission_to :forward_to_user, :project_evaluate, project: @project
          user = Decidim::User.find params[:choose_user][:user_id]

          Decidim::Projects::Admin::Evaluation::ForwardToUser.call(@project, current_user, user) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do podkoordynatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do podkoordynatora"
              redirect_to @project
            end
          end
        end

        def remove_sub_coordinator
          enforce_permission_to :forward_to_user, :project_evaluate, project: @project

          Decidim::Projects::Admin::Evaluation::ForwardToUser.call(@project, current_user, nil) do
            on(:ok) do
              flash[:notice] = "Projekt został przekazany do podkoordynatora"
              redirect_to @project
            end

            on(:invalid) do
              flash[:alert] = "Nie udało się przekazać projektu do podkoordynatora"
              redirect_to @project
            end
          end
        end

        def add_note_for_verificator
          enforce_permission_to :return_to_verificator, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::AddNoteForm).from_model(@project)
        end

        def return_to_verificator
          enforce_permission_to :return_to_verificator, :project_evaluate, project: @project
          @form = form(Decidim::Projects::Admin::AddNoteForm).from_params(params[:evaluation_note].merge(project_id: @project.id))

          Decidim::Projects::Admin::Evaluation::ReturnToVerificator.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = "Przekazano ocenę projektu ponownie do weryfikatora"
              redirect_to @project
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się przekazać oceny do weryfikatora"
              render :add_note_for_verificator
            end
          end
        end

        def find_evaluated_project
          @project ||= Decidim::Projects::Project.find params[:project_id]
        end
      end
    end
  end
end
