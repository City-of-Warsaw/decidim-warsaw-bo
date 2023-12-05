# frozen_string_literal: true

module Decidim::AdminExtended
  # Controller that allows to manage faq groups, which store faqs in admin panel
  class Admin::FaqGroupsController < Admin::ApplicationController
    layout "decidim/admin/pages"

    def new
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqGroupForm).instance
    end

    def create
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqGroupForm).from_params(params)

      Admin::CreateFaqGroup.call(@form) do
        on(:ok) do
          flash[:notice] = I18n.t("faq_groups.create.success", scope: "decidim.admin_extended.admin")
          redirect_to faqs_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("faq_groups.create.errors", scope: "decidim.admin_extended.admin")
          render :new
        end
      end
    end

    def edit
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqGroupForm).from_model(faq_group)
    end

    def update
      enforce_permission_to :update, :organization, organization: current_organization
      @form = form(Admin::FaqGroupForm).from_params(params)

      Admin::UpdateFaqGroup.call(faq_group, @form) do
        on(:ok) do
          flash[:notice] = I18n.t("faq_groups.update.success", scope: "decidim.admin_extended.admin")
          redirect_to faqs_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("faq_groups.update.errors", scope: "decidim.admin_extended.admin")
          render :edit
        end
      end
    end

    def destroy
      enforce_permission_to :update, :organization, organization: current_organization
      faq_group.destroy!
      flash[:notice] = I18n.t("faq_groups.destroy.success", scope: "decidim.admin_extended.admin")
      redirect_to faqs_path
    end

    private

    def faq_group
      @faq_group ||= FaqGroup.find_by(id: params[:id])
    end
  end
end
