# frozen_string_literal: true

module Decidim
  module UsersExtended
    class AdAuthorizationService

      GROUP_MATCH = /CN=#{ENV['AD_BASE_FILTER']}*/

      # Public: Initializes the command.
      #
      # login    - user login
      # password - user AD password
      def initialize(login, password)
        @login = login
        @password = password

        @ad_service = Decidim::UsersExtended::AdService.new
      end

      def call
        return false if @login.blank? || @password.blank?

        @ad_user = @ad_service.get_ad_user(@login)
        return unless ad_user

        # validate password with AD
        return unless ad_user_authenticated?

        find_or_create_user(ad_user)
        update_user(ad_user)

        # check if user has valid role in system
        return unless ad_user_authorized?
        @user
      end

      attr_accessor :ad_user
      attr_reader :user

      def ad_user_authenticated?
        @ad_service.initialize_ldap_con(ad_user.ad_dn, @password).bind
      end

      def ad_user_authorized?
        !!ad_user_role(ad_user)
      end

      def ad_user_role(ad_user)
        @user_role ||= ad_user.find_ad_group_for(GROUP_MATCH)
      end

      def find_or_create_user(ad_user)
        @user = find_user(ad_user) || create_user(ad_user)
      end

      # Create new user form AD data
      def create_user(ad_user)
        password = gen_password
        user = Decidim::User.new(
          email: ad_user.email,
          ad_name: ad_user.ad_name,
          name: ad_user.first_name,
          nickname: gen_nickname(ad_user),
          first_name: ad_user.first_name,
          last_name: ad_user.last_name,
          password: password,
          password_confirmation: password,
          organization: Current.organization,
          tos_agreement: true,
          locale: 'pl',
          skip_invitation: true,
          confirmed_at: DateTime.current,
          accepted_tos_version: Decidim::Organization.last.tos_version,
          admin_terms_accepted_at: DateTime.current
        )
        user.save(validate: false)
        user
      end

      # Find user by ad_name or e-mail
      def find_user(ad_user)
        Decidim::User.find_by(ad_name: ad_user.ad_name).presence || Decidim::User.find_by(email: ad_user.email)
      end

      # Update user's data from AD
      def update_user(ad_user)
        return unless @user

        @user.update_columns(
          email: ad_user.email,
          admin: true,
          nickname: user.nickname.presence || gen_nickname(ad_user),
          first_name: ad_user.first_name,
          last_name: ad_user.last_name,
          ad_name: ad_user.ad_name,
          ad_role: ad_user_role(ad_user),
          ad_access_deactivate_date: ad_user_authorized? ? nil : Time.current,
          # fix for all the invitations that were sent by mistake
          confirmed_at: DateTime.current,
          confirmation_sent_at: nil,
          confirmation_token: nil
        )
      end

      def authenticate(login, password)
        if login && password
          ldap = AdService.new

          attrs = ldap.authenticate(login, password)
          initialize_ldap_con(attrs.dn, password).bind
        end
      end

      # Remove polish letters from string
      def unify_letters(str)
        str.gsub(' ', '').gsub('ą', 'a').gsub('Ą', 'A').gsub('ę', 'e').gsub('ę', 'E').gsub('ć', 'c').gsub('Ć', 'C').gsub('ł', 'l').gsub('Ł', 'L').
          gsub('ń', 'n').gsub('Ń', 'N').gsub('ó', 'o').gsub('Ó', 'O').gsub('ś', 's').gsub('Ś', 'S').
          gsub('ź', 'z').gsub('ż', 'z').gsub('Ż', 'Z').gsub('.', '')
      end

      # Generate nickname from first and last name
      def gen_nickname(ad_user)
        unify_letters("#{ad_user.first_name}-#{ad_user.last_name}-#{Time.current.to_i}".first(20))
      end

      # Generate random password
      def gen_password
        "#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}"
      end

    end
  end
end
