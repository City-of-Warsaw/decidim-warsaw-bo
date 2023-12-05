# frozen_string_literal: true
require 'obscenity/active_model'

module Decidim
  module AdminExtended
    module Admin
      # A form object to create or update Mail Templates.
      class MailTemplateForm < Form
        attribute :name, String
        attribute :subject, String
        attribute :body, String

        validates :name, presence: true
        validates :body, presence: true, obscenity: { message: "Nie może zawierać wulgaryzmów" }
        validates :subject, presence: true
      end
    end
  end
end
