# frozen_string_literal: true

module Decidim
  module CoreExtended
    module Account
      class UserPasswordsController < Decidim::CoreExtended::ApplicationController
        include Decidim::UserProfile
        helper Decidim::ResourceHelper
        layout 'decidim/core_extended/user_profile'

        helper_method :password_form

        def update
          enforce_permission_to :show, :user, current_user: current_user
          @account = form(Decidim::AccountForm).from_model(current_user)

          if password_form.valid?
            # current_user.update(password: password_form.password)
            current_user.reset_password(password_form.password, password_form.password_confirmation)
            bypass_sign_in(current_user)
            redirect_to decidim.account_path, notice: "Hasło zostało zmienione poprawnie."
          else
            flash[:error] = "Wystąpiły błędy podczas zmiany hasła"
            render 'decidim/account/show'
          end
        end

        private

        def password_form
          @password_form ||= form(Decidim::CoreExtended::UserPasswordForm).from_params(params)
        end
      end
    end
  end
end
