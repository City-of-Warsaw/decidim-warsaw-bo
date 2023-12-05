# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows managing all Recipients (dictionary) at the admin panel.
  class Admin::RecipientsController < Decidim::AdminExtended::Admin::ApplicationController
    layout "decidim/admin/settings"
    helper_method :recipients

    def index
      enforce_permission_to :update, :organization, organization: current_organization
      render 'index'
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::RecipientForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::RecipientForm).from_params(params)

      Decidim::AdminExtended::Admin::CreateRecipient.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("recipients.create.success", scope: "decidim.admin")
          redirect_to recipients_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("recipients.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::RecipientForm).from_model(recipient)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Decidim::AdminExtended::Admin::RecipientForm).from_params(params)

      Decidim::AdminExtended::Admin::UpdateRecipient.call(recipient, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("recipients.update.success", scope: "decidim.admin")
          redirect_to recipients_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("recipients.update.error", scope: "decidim.admin")
          render :edit
        end
      end
    end

    private

    def recipient
      @recipient ||= recipients.find params[:id]
    end

    def recipients
      Recipient.sorted_by_name
    end

  end
end
