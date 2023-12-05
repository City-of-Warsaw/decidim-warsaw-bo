# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Controller that allows managing formal evaluations in admin panel.
      class FormalEvaluationsController < Admin::ApplicationController
        include ::Decidim::MultipleAttachmentsMethods
        helper Decidim::TooltipHelper
        helper Projects::Admin::ProjectsHelper

        before_action :find_evaluated_project, only: [:new, :create, :show, :edit, :update,
                                                      :submit_for_formal, :finish_formal, :accept_formal,
                                                      :add_note_for_verificator, :return_to_verificator]
        before_action :find_formal_evaluation, only: [:show, :edit, :update]

        def new
          enforce_permission_to :edit_formal, :project_evaluate, project: @project

          @form = form(FormalEvaluationForm).instance
          @form.with_signatures = 3 unless @project.is_paper? # podpisy domyslnie mają "nie dotyczy" dla elektronicznych
        end

        def create
          enforce_permission_to :edit_formal, :project_evaluate, project: @project

          @form = form(FormalEvaluationForm).from_params(params[:formal_evaluation])
          Decidim::Projects::Admin::Evaluation::CreateFormalEvaluation.call(@form, current_user, @project) do
            on(:ok) do |formal_evaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Evaluation::AcceptFormal.call(@project, current_user) do
                  on(:ok) do
                    flash[:notice] = "Zapisano zmiany i zaakceptowano ocenę formalną"
                    redirect_to @project
                  end

                  on(:invalid) do
                    flash[:alert] = "Nie udało się zaakceptować oceny projektu"
                    redirect_to action: :new
                  end
                end
              else
                flash[:notice] = "Utworzono ocenę formalną."
                redirect_to(edit_project_formal_evaluation_path(@project, formal_evaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się utworzyć oceny formalnej."
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :edit_formal, :project_evaluate, project: @project
          @formal_evaluation = @project.formal_evaluation
          create_log(@project, :edit_f_evaluation)

          @form = form(FormalEvaluationForm).from_model(@formal_evaluation)
        end

        def update
          enforce_permission_to :edit_formal, :project_evaluate, project: @project

          @form = form(FormalEvaluationForm).from_params(params[:formal_evaluation].merge(id: @project.formal_evaluation.id, evaluation_id: @project.formal_evaluation.id))
          Decidim::Projects::Admin::Evaluation::UpdateFormalEvaluation.call(@form, current_user) do
            on(:ok) do |formal_evaluation|
              if subaction_for?('accept')
                Decidim::Projects::Admin::Evaluation::AcceptFormal.call(@project, current_user) do
                  on(:ok) do
                    flash[:notice] = "Zapisano zmiany i zaakceptowano ocenę formalną"
                    redirect_to @project
                  end

                  on(:invalid) do
                    flash[:alert] = "Nie udało się zaakceptować oceny projektu"
                    redirect_to(edit_project_formal_evaluation_path(@project, formal_evaluation))
                  end
                end
              else
                flash[:notice] = 'Zaktualizowano ocenę'
                redirect_to(edit_project_formal_evaluation_path(@project, formal_evaluation))
              end
            end

            on(:invalid) do
              flash.now[:alert] = "Nie udało się zaktualizować oceny"
              render :edit
            end
          end
        end

        def show
          @evaluation = @formal_evaluation
          respond_to do |format|
            format.html { redirect_to action: :edit }
            format.pdf do
              render pdf: "pdf"   # File name excluding ".pdf" extension.
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

        private

        def find_evaluated_project
          @project ||= Decidim::Projects::Project.find params[:project_id]
        end

        def find_formal_evaluation
          @formal_evaluation = @project.formal_evaluation
        end
      end
    end
  end
end
