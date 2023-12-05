# frozen_string_literal: true

Decidim::UpdateAccount.class_eval do
  # Overwritten method, added fix_to_bypass_validations
  def call
    fix_to_bypass_validations
    return broadcast(:invalid) unless @form.valid?

    update_personal_data
    update_avatar
    update_password

    if @user.valid?
      check_changes_and_create_logs(@user)
      @user.save!
      notify_followers
      broadcast(:ok, @user.unconfirmed_email.present?)
    else
      @form.errors.add :avatar, @user.errors[:avatar] if @user.errors.key? :avatar
      broadcast(:invalid)
    end
  end

  private

  # in original form nickname and email are required, but for update we dont allow this
  def fix_to_bypass_validations
    @form.email = @user.email
    @form.nickname = @user.nickname
  end

  def create_log(user, action)
    Decidim.traceability.perform_action!(
      action,
      user,
      user,
      visibility: 'admin-only'
    )
  end

  def check_changes_and_create_logs(user)
    create_log(user, 'user_email_on_notification') if user.email_on_notification_changed?
    create_log(user, 'user_allow_private_message') if user.allow_private_message_changed?
    create_log(user, 'user_inform_me_about_comments') if user.inform_me_about_comments_changed?
    create_log(user, 'user_newsletter') if user.newsletter_changed?
    create_log(user, 'user_watched_implementations_updates') if user.watched_implementations_updates_changed?
    create_log(user, 'user_inform_about_admin_changes') if user.inform_about_admin_changes_changed?
    create_log(user, 'user_updated_account') if user.first_name_changed? || user.last_name_changed? || user.gender_changed?
  end

  def update_personal_data
    # custom
    @user.gender = @form.gender
    @user.first_name = @form.first_name
    @user.last_name = @form.last_name

    # agreements
    @user.email_on_notification = @form.email_on_notification
    @user.allow_private_message = @form.allow_private_message
    @user.inform_me_about_comments = @form.inform_me_about_comments
    @user.newsletter = @form.newsletter
    @user.watched_implementations_updates = @form.watched_implementations_updates
    @user.inform_about_admin_changes = @form.inform_about_admin_changes
  end
end
