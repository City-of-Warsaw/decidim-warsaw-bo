# frozen_string_literal: true

Decidim::AdminLog::UserPresenter.class_eval do
  private

  def action_string
    case action
    when 'grant_id_documents_offline_verification', 'invite', 'officialize', 'remove_from_admin', 'show_email', 'unofficialize', 'block', 'unblock', 'promote', 'transfer'
      "decidim.admin_log.user.#{action}"
    when 'user_login', 'user_logout', 'user_login_peum'
      # custom - city users
      "decidim.admin_log.user.#{action}"
    when "login", "assign_role", "update_user", "deactivate_ad_user", "activate_ad_user", "auto_deactivate_ad_user", "auto_activate_ad_user"
      "decidim.admin_log.user.#{action}"
    when 'user_updated_account', 'user_show_my_name', 'user_watched_implementations_updates', 'user_inform_about_admin_changes', 'user_inform_me_about_proposal', 'user_email_on_notification', 'user_allow_private_message', 'user_inform_me_about_comments', 'user_newsletter'
      # custom - ad users
      "decidim.admin_log.user.#{action}"
    when 'users_list_export', 'admins_list_export', 'admins_logs_export'
      "decidim.admin_log.user.#{action}"
    else
      super
    end
  end
end
