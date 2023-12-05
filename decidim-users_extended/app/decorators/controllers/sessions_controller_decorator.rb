# frozen_string_literal: true

Decidim::Devise::SessionsController.class_eval do

  def destroy
    current_user.invalidate_all_sessions!
    create_log(current_user, :user_logout)

    if params[:translation_suffix].present?
      super { set_flash_message! :notice, params[:translation_suffix], { scope: "decidim.devise.sessions" } }
    else
      super
    end
  end

  def after_sign_in_path_for(user)
    create_log(user, :user_login) if user.present?

    if user.present? && user.blocked?
      check_user_block_status(user)
    # elsif first_login_and_not_authorized?(user) && !user.admin? && !pending_redirect?(user)
    #   decidim_verifications.first_login_authorizations_path
    else
      decidim.root_path
    end
  end

  def create_log(user, log_type)
    Decidim.traceability.perform_action!(
      log_type,
      user,
      user,
      visibility: "admin-only"
    )
  end

  def pending_redirect?(user)
    store_location_for(user, stored_location_for(user))
  end

  def after_sign_out_path_for(user)
    decidim.root_path
  end
end
