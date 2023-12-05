# frozen_string_literal: true

module Decidim::UsersExtended
  class SessionsController < Decidim::ApplicationController
    include Decidim::FormFactory
    helper Decidim::DecidimFormHelper
    helper Decidim::MetaTagsHelper

    skip_before_action :verify_authenticity_token, only: :peum_callback

    layout "layouts/decidim/admin/login"

    def new
      @form = form(Decidim::UsersExtended::AdminSessionForm).instance
    end

    def create
      @form = form(Decidim::UsersExtended::AdminSessionForm).from_params(params[:admin_session])

      Decidim::UsersExtended::CreateAdminSession.call(@form) do
        on(:ok) do |user|
          sign_in(:user, user)

          flash[:notice] = I18n.t("admin_session.create.success", scope: "decidim.ad_access")
          redirect_to decidim_admin.root_path
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("admin_session.create.error", scope: "decidim.ad_access")
          render :new
        end
      end
    end

    def peum_login
      redirect_to Decidim::UsersExtended::PeumService.new.peum_url
    end

    def peum_callback
      Decidim::UsersExtended::PeumService.call(params[:code]) do
        on(:ok) do |user_info|
          user = find_or_create_user(user_info)
          if user
            sign_in(:user, user)
            create_log(user, :user_login_peum)
            flash[:notice] = 'Zalogowano pomyślnie'
          else
            flash[:error] = 'Niepoprawne dane logowania'
          end
        end

        on(:invalid) do
          flash[:error] = 'Niepoprawne dane logowania'
        end
        redirect_to decidim.root_path
      end
    end

    def xss_test_oauth
      # https://test.moja.warszawa19115.pl/ident/oauth2/authorize?response_type=code&client_id=foKsWC54TDCQD0_5iFh9rlKpsaca&redirect_uri=http://localhost:3000/auth/warszawa19115/callback&nonce=nEdd4tFU6jVNKb7R&state=PozF6sJKePvbgizb&scope=email profile openid given_name family_name
      # => code e732fdc7-223b-39a2-93ef-e8d564101890

      # https://test.moja.warszawa19115.pl/oauth/authorize?client_id=foKsWC54TDCQD0_5iFh9rlKpsaca&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Fauth%2Fwarszawa19115%2Fcallback&response_type=code

      # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      require 'oauth2'
      client_id = 'foKsWC54TDCQD0_5iFh9rlKpsaca'
      client_secret = 'YdF8S9jyvPRxQHZZSgKKUFMRKPwa'
      # client = OAuth2::Client.new(client_id, 'client_secret', site: 'https://test.moja.warszawa19115.pl', authorize_url: "/ident/oauth2/authorize", ssl: false)
      # client = OAuth2::Client.new(client_id, 'client_secret', site: 'https://test.moja.warszawa19115.pl', authorize_url: "/ident/oauth2/authorize", ssl: OpenSSL::SSL::VERIFY_NONE)
      client = OAuth2::Client.new(client_id, 'client_secret', site: 'https://test.moja.warszawa19115.pl', authorize_url: "/ident/oauth2/authorize", ssl: { verify: false })
      client.auth_code.authorize_url(redirect_uri: 'http://localhost:3000/auth/warszawa19115/callback')
      # => url => code
      authorization_code = '74aeacdd-e5dd-3766-a443-dbe33007ceec'
      token = client.auth_code.get_token(authorization_code, redirect_uri: 'http://localhost:3000/auth/warszawa19115/callback', headers: {})


      # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
      ctx = OpenSSL::SSL::SSLContext.new
      ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      # HTTP.get("https://www.google.com", :ssl_context => ctx)

      response = HTTP.post(
        'https://test.moja.warszawa19115.pl/ident/oauth2/token',
        form: {
          grant_type: 'authorization_code',
          client_secret: client_secret,
          code: authorization_code,
          redirect_uri: 'http://localhost:3000/auth/warszawa19115/callback'
        },
        :ssl_context => ctx
      )
      JSON.parse response.to_s
    end

    private

    def find_or_create_user(user_info)
      email = user_info['email']
      return unless email

      user = Decidim::User.find_by email: email
      return user if user

      given_name = user_info['given_name']
      family_name = user_info['family_name']
      generated_password = SecureRandom.hex 16

      user = Decidim::User.new(
        tos_agreement: true,
        accepted_tos_version: Time.current,
        email: email,
        name: "name#{Time.current.to_i}",
        nickname: "user-#{Time.current.to_i}",
        display_name: "user-#{Time.current.to_i}",
        first_name: given_name,
        last_name: family_name,
        password: generated_password,
        password_confirmation: generated_password,
        organization: Current.organization,
        locale: 'pl',
        anonymous_number: rand(Time.current.to_i),
        skip_invitation: true,
        confirmed_at: Time.current
      )

      if user.save
        user
      else
        nil
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
  end
end
