# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows to manage faqs, use and list groups for them, in admin panel
  class Admin::FaqsController < Admin::ApplicationController
    layout "decidim/admin/pages"

    helper_method :faq_groups

    def index
      enforce_permission_to :update, :organization, organization: current_organization
    end

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqForm).from_params(params)

      Admin::CreateFaq.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("faqs.create.success", scope: "decidim.admin_extended.admin")
          redirect_to faqs_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("faqs.create.errors", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqForm).from_model(faq)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqForm).from_params(params)

      Admin::UpdateFaq.call(faq, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("faqs.update.success", scope: "decidim.admin_extended.admin")
          redirect_to faqs_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("faqs.update.errors", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      faq.destroy!
      flash[:notice] = I18n.t("faqs.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to faqs_path
    end

    private

    def faq_groups
      FaqGroup.sorted_by_weight
    end

    def faq
      @faq ||= Faq.find_by(id: params[:id])
    end
  end
end
