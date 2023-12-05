# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Project in admin panel.
      class ProjectAuthorForm < Decidim::Form

        attribute :first_name, String
        attribute :last_name, String
        attribute :gender, String
        attribute :phone_number, String
        attribute :email, String

        ################
        # address fields
        attribute :street, String
        attribute :street_number, String
        attribute :flat_number, String
        attribute :zip_code, String
        attribute :city, String
        attribute :show_author_name, Virtus::Attribute::Boolean
        attribute :inform_author_about_implementations, Virtus::Attribute::Boolean
        attribute :signed, Virtus::Attribute::Boolean
        attribute :confirmation_status, String

        def map_model(model)
          self.first_name = model['first_name']
          self.last_name = model['last_name']
          self.city = model['city']
          self.gender = model['gender']
          self.street = model['street']
          self.flat_number = model['flat_number']
          self.phone_number = model['phone_number']
          self.street_number = model['street_number']
          self.show_author_name = model['show_author_name']
          self.confirmation_status = model['confirmation_status']
          self.inform_author_about_implementations = model['inform_author_about_implementations']
        end
      end
    end
  end
end
