# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing reevaluations in admin panel.
      class ReevaluationsController < Admin::ApplicationController
        helper Decidim::TooltipHelper
        helper Projects::Admin::ProjectsHelper

        helper_method :project

        def new
          enforce_permission_to :edit_reevaluation, :project_evaluate, project: project
          @form = form(Decidim::Projects::Admin::ReevaluationForm).instance
        end

        def create
          @form = form(Decidim::Projects::Admin::ReevaluationForm).from_params(params)

          Decidim::Projects::Admin::Reevaluation::CreateReevaluation.call(@form, current_user, project) do
            on(:ok) do |reevaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Reevaluation::SubmitToOrganizationAdmin.call(project.appeal, current_user) do
                  on(:ok) do
                    flash[:notice] = 'Ponowna ocena projektu została przekazana do CKSu'
                    redirect_to project
                  end

                  on(:invalid) do
                    flash[:alert] = 'Nie udało się przekazać ponownej oceny projektu do CKSu'
                    redirect_to(edit_project_reevaluation_path(project, reevaluation))
                  end
                end
              elsif subaction_for?('accept-full')
                Decidim::Projects::Admin::Reevaluation::FinishReevaluation.call(project.appeal, current_user) do
                  on(:ok) do
                    flash[:notice] = 'Zatwierdzono ostateczną ocenę projektu'
                    redirect_to project
                  end
                  on(:invalid_budget) do
                    flash[:alert] = 'Wartość budżetu nie może być pusta ani nie może przekraczać limitu.'
                    redirect_to project
                  end
                  on(:invalid_reevaluation_result) do
                    flash[:alert] = 'Zatwierdzenie oceny wymaga wprowadzenia wyniku rozpatrzenia odwołania (oceny, osoby i daty)'
                    redirect_to project
                  end
                  on(:invalid) do
                    flash[:alert] = 'Nie udało się zatwierdzić ostatecznej oceny projektu'
                    redirect_to(edit_project_reevaluation_path(project, reevaluation))
                  end
                end
              else
                flash[:notice] = 'Utworzono ponowną ocenę.'
                redirect_to(edit_project_reevaluation_path(project, reevaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się utworzyć ponownej oceny.'
              render :new
            end
          end
        end

        def edit
          @reevaluation = project.reevaluation
          create_log(project, :edit_reevaluation)

          @form = form(Decidim::Projects::Admin::ReevaluationForm).from_model(@reevaluation)
        end

        def update
          @reevaluation = project.reevaluation

          @form = form(Decidim::Projects::Admin::ReevaluationForm).from_params(params.merge(reevaluation_id: @reevaluation.id))

          Decidim::Projects::Admin::Reevaluation::UpdateReevaluation.call(@form, current_user) do
            on(:ok) do |reevaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Reevaluation::SubmitToOrganizationAdmin.call(project.appeal, current_user) do
                  on(:ok) do
                    flash[:notice] = 'Ponowna ocena projektu została przekazana do CKSu'
                    redirect_to project
                  end

                  on(:invalid) do
                    flash[:alert] = 'Nie udało się przekazać ponownej oceny projektu do CKSu'
                    redirect_to(edit_project_reevaluation_path(project, reevaluation))
                  end
                end
              elsif subaction_for?('accept-coordinator')
                Decidim::Projects::Admin::Reevaluation::AcceptCoordinatorReevaluation.call(project.appeal, current_user) do
                  on(:ok) do
                    flash[:notice] = 'Odwołanie zostało zaakceptowane'
                    redirect_to project
                  end

                  on(:invalid) do
                    flash.now[:alert] = 'Nie udało się zaakceptowac odwołania'
                    redirect_to project
                  end
                end
              elsif subaction_for?('accept-full')
                Decidim::Projects::Admin::Reevaluation::FinishReevaluation.call(project.appeal, current_user) do
                  on(:ok) do
                    flash[:notice] = 'Zatwierdzono ostateczną ocenę projektu'
                    redirect_to project
                  end
                  on(:invalid_budget) do
                    flash[:alert] = 'Wartość budżetu nie może być pusta ani nie może przekraczać limitu.'
                    redirect_to project
                  end
                  on(:invalid_reevaluation_result) do
                    flash[:alert] = 'Zatwierdzenie oceny wymaga wprowadzenia wyniku rozpatrzenia odwołania (oceny, osoby i daty)'
                    redirect_to project
                  end
                  on(:invalid) do
                    flash[:alert] = 'Nie udało się zatwierdzić ostatecznej oceny projektu'
                    redirect_to(edit_project_reevaluation_path(project, reevaluation))
                  end
                end
              else
                flash[:notice] = 'Zaktualizowano ponowną ocenę.'
                redirect_to(edit_project_reevaluation_path(project, reevaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaktualizować ponownej oceny.'
              render :edit
            end
          end
        end

        def show
          @evaluation = project.reevaluation
          @form = form(Decidim::Projects::Admin::ReevaluationForm).from_model(@evaluation)

          respond_to do |format|
            format.html { redirect_to action: :edit }
            format.pdf do
              render pdf: 'pdf' # File name excluding ".pdf" extension.
            end
          end
        end

        # przekazanie odwolania do koordynatora
        def finish_appeal_draft
          enforce_permission_to :finish_appeal_draft, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::FinishAppealDraft.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Odwołanie przekazano do koordynatora'
              redirect_to appeals_path
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się przekazać odwołania do koordynatora.'
              redirect_to appeals_path
            end
          end
        end

        # akceptacja odwolania przez koordynatora
        def accept_paper_appeal
          enforce_permission_to :accept_paper_appeal, :project_reevaluate, project: project

          Decidim::Projects::Admin::Reevaluation::AcceptPaperAppeal.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Odwołanie zostało zaakceptowane'
              redirect_to appeals_path
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaakceptować odwołania'
              redirect_to appeals_path
            end
          end
        end

        # przypisanie weryfikatora
        def submit_for_verification
          enforce_permission_to :submit_for_verification, :project_reevaluate, project: project
          evaluator = Decidim::User.find_by(id: params[:choose_verificator][:evaluator_id])
          Decidim::Projects::Admin::Reevaluation::SubmitForVerification.call(project.appeal, current_user, evaluator) do
            on(:ok) do
              flash[:notice] = 'Projekt przekazano do weryfikatora'
              redirect_to project and return
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się przekazać projektu do weryfikatora'
              redirect_to project and return
            end
          end
        end

        def finish_appeal_verification
          enforce_permission_to :finish_appeal_verification, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::FinishAppealVerification.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Ponowna ocena projektu została przekazana do koordynatora'
              redirect_to project
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się przekazać oceny projektu do koordynatora'
              redirect_to project
            end
          end
        end

        def return_from_admin_to_coordinators
          enforce_permission_to :return_from_admin_to_coordinators, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::ReturnFromAdminToCoordinators.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Projekt został zwrócony do koordynatora'
              redirect_to project
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zwrócić oceny projektu do koordynatora'
              redirect_to project
            end
          end
        end

        def accept_coordinator_reevaluation
          enforce_permission_to :accept_coordinator_reevaluation, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::AcceptCoordinatorReevaluation.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Odwołanie zostało zaakceptowane'
              redirect_to project
            end

            on(:invalid) do
              flash.now[:alert] = 'Nie udało się zaakceptowac odwołania'
              redirect_to project
            end
          end
        end

        def submit_to_organization_admin
          enforce_permission_to :submit_to_organization_admin, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::SubmitToOrganizationAdmin.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Ponowna ocena projektu została przekazana do CKSu'
              redirect_to project
            end

            on(:invalid) do
              flash[:alert] = 'Nie udało się przekazać ponownej oceny projektu do CKSu'
              redirect_to project
            end
          end
        end

        def finish_reevaluation
          enforce_permission_to :finish_reevaluation, :project_reevaluate, project: project
          Decidim::Projects::Admin::Reevaluation::FinishReevaluation.call(project.appeal, current_user) do
            on(:ok) do
              flash[:notice] = 'Zatwierdzono ostateczną ocenę projektu'
              redirect_to project
            end
            on(:invalid_budget) do
              flash[:alert] = 'Wartość budżetu nie może być pusta ani nie może przekraczać limitu.'
              redirect_to project
            end
            on(:invalid_reevaluation_result) do
              flash[:alert] = 'Zatwierdzenie oceny wymaga wprowadzenia wyniku rozpatrzenia odwołania (oceny, osoby i daty)'
              redirect_to project
            end
            on(:invalid) do
              flash[:alert] = 'Nie udało się zatewierdzić ostatecznej oceny projektu'
              redirect_to project
            end
          end
        end

        def choose_verificator
          enforce_permission_to :submit_for_verification, :project_reevaluate, project: project
          @form = form(Decidim::Projects::Admin::ChooseVerificatorForm).from_model(project)
        end

        def project
          @project ||= Decidim::Projects::Project.find params[:project_id]
        end

        def find_reevaluated_project
          @project ||= Decidim::Projects::Project.find params[:project_id]
          @appeal = @project.appeal
        end
      end
    end
  end
end
