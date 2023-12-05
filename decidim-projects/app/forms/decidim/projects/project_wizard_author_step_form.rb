# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to update Projects.
    # This form is used on second step of creating projects wizard
    # and allows updating projects draft as it contains no validations.
    class ProjectWizardAuthorStepForm < Decidim::Form

      # user data fields
      attribute :first_name, String
      attribute :last_name, String
      attribute :gender, String
      attribute :phone_number, String
      attribute :email, String
      attribute :coauthor_email_one, String
      attribute :coauthor_email_two, String

      # address fields
      attribute :street, String
      attribute :street_number, String
      attribute :flat_number, String
      attribute :zip_code, String
      attribute :city, String

      # agreements fields
      attribute :show_author_name, GraphQL::Types::Boolean
      attribute :inform_author_about_implementations, GraphQL::Types::Boolean
      attribute :email_on_notification, GraphQL::Types::Boolean

      def map_model(model)
        super

        # creator = model.creator_author
        self.first_name = model.first_name.presence || model.creator_author.first_name
        self.last_name = model.last_name.presence || model.creator_author.last_name
        self.gender = model.gender.presence || model.creator_author.gender
        self.phone_number = model.phone_number
        self.email = model.email.presence || model.creator_author.email
        # address
        self.street = model.street
        self.street_number = model.street_number
        self.flat_number = model.flat_number
        self.zip_code = model.zip_code
        self.city = model.city.presence || 'Warszawa'
        # agreements
        self.show_author_name = model.show_author_name
        self.inform_author_about_implementations = model.inform_author_about_implementations
        self.email_on_notification = model.email_on_notification
      end

      def coauthor_emails
        return [] if coauthor_email_one.blank? && coauthor_email_two.blank?

        [coauthor_email_one, coauthor_email_two]
      end
    end
  end
end
