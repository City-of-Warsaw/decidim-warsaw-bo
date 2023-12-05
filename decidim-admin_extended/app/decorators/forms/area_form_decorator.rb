# frozen_string_literal: true

# OVERWRITTEN DECIDIM FORM
# A form object to create or update areas
# Class was provided with attributes for adding and removing icons from Areas
# and Decidim validations for files uploads
Decidim::Admin::AreaForm.class_eval do
  include Decidim::HasUploadValidations

  attribute :active, GraphQL::Types::Boolean
  attribute :icon
  attribute :remove_icon
end
