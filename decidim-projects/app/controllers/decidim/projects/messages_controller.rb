module Decidim
  module Projects
    # Controller that allows sending private messages to project
    class MessagesController < Decidim::Projects::ApplicationController
      include Decidim::FormFactory
      include Decidim::NeedsPermission

      helper Decidim::Projects::ApplicationHelper

      helper_method :project

      def send_private_message
        redirect_to('/projects', alert: 'Nie znaleziono projektu') and return unless project

        @private_message_form = form(Decidim::Projects::PrivateMessageForm).from_params(params[:private_message].merge(project_id: project.id))
        mt = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'new_private_message')

        if @private_message_form.valid? && mt
          Decidim::Projects::TemplatedMailerJob.perform_later(
            project,
            project.creator_author,
            mt,
            additional_data = {
              sender_email: @private_message_form.email,
              private_message_body: @private_message_form.body,
              attachments: @private_message_form.add_documents.map { |a| [a.original_filename, a.read] }
            }
          )
          flash[:notice] = 'Wysłano wiadomość prywatną do autora projektu'
        else
          flash[:alert] = 'Nie udało się wysłać wiadomosci do autora projektu'
        end
        redirect_to Decidim::ResourceLocatorPresenter.new(project).path
      end

      private
      def project
        @project ||= begin
                       proj = Decidim::Projects::Project.published.not_hidden.find_by(id: params[:id])
                       proj = Decidim::Projects::Project.from_author(current_user).find_by(id: params[:id]) if !proj && current_user
                       proj
                     end
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