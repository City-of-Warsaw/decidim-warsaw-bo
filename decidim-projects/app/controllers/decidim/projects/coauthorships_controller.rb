# frozen_string_literal: true

module Decidim
  module Projects
    # Controller that allows managing project coauthors
    class CoauthorshipsController < Decidim::Projects::ApplicationController
      include Decidim::FormFactory
      include Decidim::NeedsPermission

      helper Decidim::Projects::ApplicationHelper

      helper_method :project, :coauthorship

      def edit
        unless current_user
          redirect_to(decidim.new_user_session_path, alert: 'Zaloguj się i kliknij ponownie w link z maila, by móc potwierdzić współautorstwo projektu') and return
        end
        redirect_to('/projects', alert: 'Nie znaleziono projektu') and return unless project

        unless coauthorship
          flash[:alert] = 'Nie znaleziono zaproszenia do współautorstwa, lub zostalo ono anulowane przez autora projektu'
          redirect_to Decidim::ResourceLocatorPresenter.new(project).path
        end

        @form = form(Decidim::Projects::ProjectAcceptCoauthorForm).from_params(coauthor_data)
      end

      def update
        enforce_permission_to :coauthor, :project, project: project

        @form = form(Decidim::Projects::ProjectWizardAuthorStepWithValidationsForm).from_params(params[:coauthorship].merge({ project_id: project.id }))
        AcceptCoauthorship.call(coauthorship, @form, current_user) do
          on(:ok) do
            flash[:notice] = 'Potwierdzono współautorstwo'
            redirect_to Decidim::ResourceLocatorPresenter.new(project).path
          end

          on(:invalid) do
            flash.now[:alert] = 'Nie udało sie potwierdzić współautorstwa'
            render :edit
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

      def coauthorship
        @coauthorship ||= project.coauthorships.for_acceptance.for_decidim_users.find_by(decidim_author_id: current_user.id)
      end

      def coauthor_data
        # if project.coauthorships.for_acceptance.first.author == @current_user.email
        #   project.coauthor1_data
        # elsif project.coauthorships.for_acceptance.last.author == @current_user.email
        #   project.coauthor2_data
        # end
        data = if project.coauthor_email_one == current_user.email
                 project.coauthor1_data
               elsif project.coauthor_email_two == current_user.email
                 project.coauthor2_data
               end
        data['first_name'] = current_user.first_name if data['first_name'].blank?
        data['last_name'] = current_user.last_name if data['last_name'].blank?
        data['gender'] = current_user.gender if data['gender'].blank?

        data
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
    end
  end
end
