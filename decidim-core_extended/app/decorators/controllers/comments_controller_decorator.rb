# frozen_string_literal: true

Decidim::Comments::CommentsController.class_eval do
  skip_before_action :ensure_commentable!, only: :hide

  def hide
    enforce_permission_to :hide, :comment, comment: comment

    Decidim::Admin::HideResource.call(@comment, current_user) do
      on(:ok) do
        # flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
        respond_to do |format|
          format.js { render :hide }
        end
      end

      on(:invalid) do
        # flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
        respond_to do |format|
          format.js { render :hide_error }
        end
      end
    end
  end

  def comment
    @comment ||= Decidim::Comments::Comment.find_by(id: params[:id])
  end
end
