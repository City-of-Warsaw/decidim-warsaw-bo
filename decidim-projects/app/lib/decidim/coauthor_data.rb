# frozen_string_literal: true

module Decidim
  class CoauthorData
    attr_accessor :email, :gender, :last_name, :first_name, :flat_number, :phone_number,
                  :city, :zip_code, :street, :street_number,
                  :show_author_name, :inform_author_about_implementations,
                  :confirmation_status, :author_user_id,
                  :email_on_notification

    def initialize(params, project_coauthorship)
      @city = params['city']
      @email = params['email']
      @gender = params['gender']
      @street = params['street']
      @zip_code = params['zip_code']
      @last_name = params['last_name']
      @first_name = params['first_name']
      @flat_number = params['flat_number']
      @phone_number = params['phone_number']
      @street_number = params['street_number']
      @show_author_name = params['show_author_name']
      @inform_author_about_implementations = params['inform_author_about_implementations']
      @confirmation_status = project_coauthorship.nil? ? false : project_coauthorship.confirmation_status
      @email_on_notification = project_coauthorship.nil? ? false : project_coauthorship.author.email_on_notification
      @author_user_id = project_coauthorship.nil? ? nil : project_coauthorship.author.id
    end

    def public_name
      if show_author_name && (first_name.present? || last_name.present?)
        "#{first_name} #{last_name}"
      else
        if gender.present?
          "#{I18n.t(gender, scope: 'decidim.users.gender', default: I18n.t('decidim.users.gender.male'))}"
        else
          "Mieszkaniec"
        end
      end
    end

    def female?
      gender == 'female'
    end

    def male?
      gender == 'male'
    end
  end
end
