# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows managing all Mail Templates at the admin panel.
  class Admin::MailTemplatesController < Decidim::AdminExtended::Admin::ApplicationController
    layout "decidim/admin/settings"
    helper_method :mail_templates

    def index
      enforce_permission_to :index, :help_sections
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::MailTemplateForm).from_model(mail_template)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::MailTemplateForm).from_params(params)

      Decidim::AdminExtended::Admin::UpdateMailTemplate.call(mail_template, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("mail_templates.update.success", scope: "decidim.admin")
          redirect_to mail_templates_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("mail_templates.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    private

    def mail_template
      @template ||= mail_templates.find params[:id]
    end

    def mail_templates
      # MailTemplate.sorted_by_name
      MailTemplate.all.order(id: :asc)
    end
  end
end
