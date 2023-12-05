# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing meritorical evaluations in admin panel.
      class MeritoricalEvaluationsController < Admin::ApplicationController
        include ::Decidim::MultipleAttachmentsMethods
        helper Decidim::TooltipHelper
        helper Projects::Admin::ProjectsHelper

        helper_method :meritorical_evaluation

        before_action :find_evaluated_project, only: [
                                                      :new,
                                                      :create,
                                                      :show,
                                                      :edit,
                                                      :update,
                                                      :submit_for_meritorical,
                                                      :finish_meritorical,
                                                      :accept_meritorical,
                                                      :finish_project_verification,
                                                      :add_note_for_verificator,
                                                      :return_to_verificator
                                                    ]

        def new
          enforce_permission_to :edit_meritorical, :project_evaluate, project: @project

          @form = form(MeritoricalEvaluationForm).instance
        end

        def create
          enforce_permission_to :edit_meritorical, :project_evaluate, project: @project

          @form = form(MeritoricalEvaluationForm).from_params(params[:meritorical_evaluation])
          Decidim::Projects::Admin::Evaluation::CreateMeritoricalEvaluation.call(@form, current_user, @project) do
            on(:ok) do |meritorical_evaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Evaluation::AcceptMeritorical.call(@project, current_user) do
                  on(:ok) do
                    flash[:notice] = "Zapisano zmiany i zaakceptowano ocenę merytoryczną"
                    redirect_to @project
                  end
                  on(:invalid_budget) do
                    flash[:alert] = "Wartość budżetu nie może być pusta ani nie może przekraczać limitu."
                    redirect_to @project
                  end
                  on(:invalid) do
                    flash[:alert] = "Nie udało się zaakceptować oceny projektu"
                    redirect_to action: :new
                  end
                end
              else
                flash[:notice] = "Utworzono ocenę merytoryczną."
                redirect_to(edit_project_meritorical_evaluation_path(@project, meritorical_evaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się utworzyć oceny merytorycznej."
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :edit_meritorical, :project_evaluate, project: @project

          @form = form(MeritoricalEvaluationForm).from_model(meritorical_evaluation)
          create_log(@project, :edit_m_evaluation)
        end

        def update
          enforce_permission_to :edit_meritorical, :project_evaluate, project: @project

          @form = form(MeritoricalEvaluationForm).from_params(params[:meritorical_evaluation].merge(id: meritorical_evaluation.id))
          Decidim::Projects::Admin::Evaluation::UpdateMeritoricalEvaluation.call(@form, current_user) do
            on(:ok) do |meritorical_evaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Evaluation::AcceptMeritorical.call(@project, current_user) do
                  on(:ok) do
                    flash[:notice] = "Zapisano zmiany i zaakceptowano ocenę merytoryczną"
                    redirect_to @project
                  end
                  on(:invalid_budget) do
                    flash[:alert] = "Wartość budżetu nie może być pusta ani nie może przekraczać limitu."
                    redirect_to @project
                  end
                  on(:invalid) do
                    flash[:alert] = "Nie udało się zaakceptować oceny projektu"
                    redirect_to(edit_project_meritorical_evaluation_path(@project, @project.meritorical_evaluation))
                  end
                end
              elsif subaction_for?('save_and_send')
                Decidim::Projects::Admin::Evaluation::FinishMeritorical.call(@project, current_user) do
                  on(:ok) do
                    flash[:notice] = "Zapisano zmiany i projekt został przekazany do koordynatora"
                    redirect_to @project
                  end

                  on(:invalid) do
                    flash[:alert] = "Nie udało się przekazać oceny projektu do koordynatora"
                    redirect_to @project
                  end
                end
              else
                flash[:notice] = 'Zaktualizowano ocenę'
                redirect_to(edit_project_meritorical_evaluation_path(@project, @project.meritorical_evaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się zaktualizować oceny"
              render :edit
            end
          end
        end

        def show
          @evaluation = meritorical_evaluation
          respond_to do |format|
            format.html { redirect_to action: :edit }
            format.pdf do
              render pdf: "pdf"   # File name excluding ".pdf" extension.
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

        private

        def meritorical_evaluation
          @meritorical_evaluation ||= project.meritorical_evaluation.presence || project.create_meritorical_evaluation(user: current_user, details: {})
        end

        def project
          @project ||= Decidim::Projects::Project.find params[:project_id]
        end

        def find_evaluated_project
          @project ||= Decidim::Projects::Project.find params[:project_id]
        end
      end
    end
  end
end
