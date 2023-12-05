# frozen_string_literal: true

# Serwis do obslugi logowania przez PEUM
module Decidim
  module UsersExtended
    class PeumService < Rectify::Command

      attr_reader :response

      def initialize(authorization_code = nil)
        @authorization_code = authorization_code

        @peum_host = ENV.fetch("PEUM_HOST")
        @decidim_host = ENV.fetch("PEUM_CALLBACK_HOST")
        @client_id = ENV.fetch("PEUM_CLIENT_ID")
        @client_secret = ENV.fetch("PEUM_CLIENT_SECRET")

        @ctx = OpenSSL::SSL::SSLContext.new
        @ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def peum_url
        params = [
          'response_type=code',
          "client_id=#{@client_id}",
          "redirect_uri=#{@decidim_host}/auth/warszawa19115/callback",
          "nonce=#{SecureRandom.hex}",
          "state=#{ENV.fetch("PEUM_STATE")}",
          'scope=email profile view internal_login openid'
        ]
        "#{@peum_host}/ident/oauth2/authorize?#{params.join('&')}"
      end

      def call
        access_token_info = process_callback(@authorization_code)
        return broadcast(:invalid) unless access_token_info

        user_info = get_user_info(access_token_info['access_token'])
        return broadcast(:invalid) unless user_info

        broadcast(:ok, user_info)
      end

      def process_callback(authorization_code = nil)
        response = HTTP.post(
          "#{@peum_host}/ident/oauth2/token",
          form: {
            grant_type: 'authorization_code',
            client_id: @client_id,
            code: authorization_code,
            redirect_uri: "#{@decidim_host}/auth/warszawa19115/callback"
          },
          ssl_context: @ctx
        )
        access_token_info = JSON.parse(response.body)
        if response.status != 200
          return nil
        end

        access_token_info
      end

      def get_user_info(access_token)
        response = HTTP.auth("Bearer #{access_token}").get("#{@peum_host}/ident/oauth2/userinfo", ssl_context: @ctx)
        user_info = JSON.parse(response.body)
        if response.status != 200
          return nil
        end

        user_info
      end
    end
  end
end
