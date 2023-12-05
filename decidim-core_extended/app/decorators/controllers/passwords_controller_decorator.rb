# frozen_string_literal: true

Decidim::Devise::PasswordsController.class_eval do

  def create
    if user_is_from_ad
      flash[:error] = "Urzędnicy logują się domenowo, czyli tak, jak do komputera służbowego. Zmianą hasła zarządzamy m.in. w aplikacji mojekonto.um.warszawa.pl"
      redirect_to(action: :new) and return
    end

    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  private

  def user_is_from_ad
    return if resource_params[:email].blank?

    user = Decidim::User.find_by email: resource_params[:email]
    user && user.ad_name.present?
  end

end

