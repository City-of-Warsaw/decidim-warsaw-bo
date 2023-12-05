# frozen_string_literal: true

Decidim::AccountController.class_eval do
  helper Decidim::CoreExtended::ApplicationHelper
  layout 'decidim/core_extended/user_profile'

  helper_method :password_form

  def show
    enforce_permission_to :show, :user, current_user: current_user
    @account = form(Decidim::AccountForm).from_model(current_user)
  end

  private

  def password_form
    @password_form ||= form(Decidim::CoreExtended::UserPasswordForm).instance
  end
end