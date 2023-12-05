# frozen_string_literal: true

Decidim::Admin::OfficializationsController.class_eval do

  # controller action for exporting Users data to files
  def export
    enforce_permission_to :read, :officialization
    @users = collection

    create_log(current_user, 'users_list_export')
    respond_to do |format|
      format.xlsx
    end
  end

  # controller action that allows sending email with link to chenging password
  def remind_password
    user = Decidim::User.find params[:id]
    resource_params = { email: user.email, decidim_organization_id: 1 }
    Decidim::User.send_reset_password_instructions(resource_params)

    flash[:notice] = 'Link do zmiany hasła został wysłany'
    redirect_to action: :index
  end

  private

  def collection
    @collection ||= current_organization.users.not_deleted.without_ad_role.left_outer_joins(:user_moderation).merge(Decidim::Projects::SimpleUser.all)
  end

  def search_field_predicate
    :name_or_first_name_or_last_name_or_nickname_or_email_cont
  end

  def create_log(resource, log_type)
    Decidim.traceability.perform_action!(
      log_type,
      resource,
      current_user,
      visibility: "admin-only"
    )
  end

  def filters
    [:confirmed_at_null, :blocked_true]
  end
end
