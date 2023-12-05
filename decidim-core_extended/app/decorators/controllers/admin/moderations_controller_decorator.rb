# frozen_string_literal: true

Decidim::Admin::ModerationsController.class_eval do
  def hide
    enforce_permission_to :hide, permission_resource

    Decidim::Admin::HideResource.call(reportable, current_user) do
      on(:ok) do
        flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
        redirect_to redirect_path
      end

      on(:invalid) do
        flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
        redirect_to redirect_path
      end
    end
  end

  def unhide
    if reportable.reports.pluck(:reason).include?('user_hide')
      flash[:alert] = 'Nie można ponownie pokazać komentarza ukrytego przez jego autora'
      # redirect_to(action: :index, hidden: true) and return
      redirect_to(redirect_path(hidden: true)) and return
    end

    enforce_permission_to :unhide, permission_resource

    Decidim::Admin::UnhideResource.call(reportable, current_user) do
      on(:ok) do
        flash[:notice] = I18n.t("reportable.unhide.success", scope: "decidim.moderations.admin")
        redirect_to redirect_path
      end

      on(:invalid) do
        flash[:alert] = I18n.t("reportable.unhide.invalid", scope: "decidim.moderations.admin")
        redirect_to redirect_path
      end
    end
  end

  private

  def redirect_path(options = {})
    if params[:comments_view].present?
      decidim_admin_extended_admin.comments_path(options)
    else
      moderations_path(options)
    end
  end
end
