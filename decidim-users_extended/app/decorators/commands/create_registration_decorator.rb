# frozen_string_literal: true

Decidim::CreateRegistration.class_eval do

  def call
    if form.invalid?
      user = Decidim::User.has_pending_invitations?(form.current_organization.id, form.email)
      user.invite!(user.invited_by) if user
      return broadcast(:invalid)
    end

    create_user

    broadcast(:ok, @user)
  rescue ActiveRecord::RecordInvalid
    broadcast(:invalid)
  end

  private

  def create_user
    @user = Decidim::User.create!(
      email: form.email,
      name: form.name,
      nickname: form.nickname,
      password: form.password,
      password_confirmation: form.password_confirmation,
      organization: form.current_organization,
      tos_agreement: form.tos_agreement,
      newsletter_notifications_at: form.newsletter_at,
      accepted_tos_version: form.current_organization.tos_version,
      locale: form.current_locale,
      # custom
      first_name: form.first_name,
      last_name: form.last_name,
      gender: form.gender,
      email_on_notification: false,
      anonymous_number: generate_random_number
    )
  end

  def generate_random_number
    rand(Time.current.to_i)
  end
end
