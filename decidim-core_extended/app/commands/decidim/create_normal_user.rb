# frozen_string_literal: true

module Decidim
  class CreateNormalUser
    include Decidim::EmailChecker

    def initialize(email, organization, params = {})
      @email = email&.downcase&.strip
      @organization = organization
      @params = params
    end

    def find_or_create
      user = find_user
      return user if user

      if valid_email?(@email)
        user = create_user
        user.save(validate: false)
        user
      else
        create_simple_user
      end
    end

    # search user in Decidim::User or Decidim::Projects::SimpleUser by email or first_name, last_name and phone_number
    # returns User, SimpleUser or nil
    def find_user
      if @email.present? && valid_email?(@email)
        Decidim::User.find_by(email: @email) || Decidim::Projects::SimpleUser.find_by(email: @email)
      elsif first_name.present? && last_name.present? && phone_number.present?
        Decidim::User.find_by(first_name: first_name, last_name: last_name, phone_number: phone_number) ||
          Decidim::Projects::SimpleUser.find_by(first_name: first_name, last_name: last_name, phone_number: phone_number)
      end
    end

    def create_user
      Decidim::User.new({
          email: @email,
          name: nickname,
          nickname: nickname,
          first_name: first_name,
          last_name: last_name,
          password: password.presence || generate_password,
          password_confirmation: password.presence || generate_password,
          organization: @organization,
          locale: 'pl',
          skip_invitation: true,
          confirmed_at: Time.current
        }.merge(user_additional_params)
      )
    end

    def create_simple_user
      Decidim::Projects::SimpleUser.create({
          first_name: first_name,
          last_name: last_name,
          organization: @organization
        }.merge(user_additional_params)
      )
    end

    def user_additional_params
      {
        gender: @params[:gender].presence || @params['gender'],
        phone_number: phone_number,
        street: @params[:street].presence || @params['street'],
        street_number: @params[:street_number].presence || @params['street_number'],
        flat_number: @params[:flat_number].presence || @params['flat_number'],
        zip_code: @params[:zip_code].presence || @params['zip_code'],
        city: @params[:city].presence || @params['city'],
        anonymous_number: @params[:anonymous_number].presence || @params['anonymous_number'].presence || generate_anonymous_number,
        # agreements
        email_on_notification: @params[:email_on_notification] || @params['email_on_notification'] || false
      }
    end

    def password
      @params[:password].presence || @params['password']
    end

    def first_name
      @params[:first_name].presence || @params['first_name']
    end

    def last_name
      @params[:last_name].presence || @params['last_name']
    end

    def phone_number
      @params[:phone_number].presence || @params['phone_number']
    end

    def nickname
      "user-#{generate_random_number}".first(20)
    end

    def generate_anonymous_number
      @_num ||= rand(Time.current.to_i)
    end

    def generate_random_number
      rand(Time.current.to_i)
    end

    def generate_password
      @pass ||= "#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}#{::Faker::Lorem.word}#{::Faker::Number.between(from: 0, to: 9)}"
    end
  end
end
