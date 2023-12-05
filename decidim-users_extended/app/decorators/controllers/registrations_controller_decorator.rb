# frozen_string_literal: true

Decidim::Devise::RegistrationsController.class_eval do

  def new
    @form = form(Decidim::UsersExtended::RegistrationForm).from_params(
      user: { sign_up_as: "user" }
    )
  end

  def create
    @form = form(Decidim::UsersExtended::RegistrationForm)
                  .from_params(
                    params[:user]
                    .merge(
                      current_locale: current_locale,
                      tos_agreement: true
                    ))

    Decidim::CreateRegistration.call(@form) do
      on(:ok) do |user|
        if user.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(:user, user)
          respond_with user, location: after_sign_up_path_for(user)
        else
          set_flash_message! :notice, :"signed_up_but_#{user.inactive_message}"
          expire_data_after_sign_in!
          respond_with user, location: after_inactive_sign_up_path_for(user)
        end
      end

      on(:invalid) do
        flash.now[:alert] = 'Nie udało się założyć konta. Popraw błędy w formularzu i prześlij go ponownie.'
        render :new
      end
    end
  end
end
