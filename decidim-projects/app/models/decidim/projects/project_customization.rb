# frozen_string_literal: true

module Decidim::Projects
  # ProjectCustomization is a model used for creating custom fields for projects
  # and for the mandatory fields it allows to create custom labels and hints.
  # It is defined for Participatory Process.
  class ProjectCustomization < ApplicationRecord
    belongs_to :process,
               class_name: "Decidim::ParticipatoryProcess",
               foreign_key: :decidim_participatory_process_id

    # Public: Returns custom label for mandatory attribute if it was defined.
    # For required attributes it adds asterix (*) as it is not automatically added
    # via form builder due to WCAG constraints
    #
    # returns String
    def get_custom_label(attr)
      case attr
      when 'title', 'body', 'justification_info', 'category_ids', 'potential_recipient_ids',
            'scope_id', 'localization_info', 'budget_value',
            'first_name', 'last_name', 'gender', 'email',
            'street', 'street_number', 'zip_code', 'city'
        custom_names[attr].present? ? "#{custom_names[attr]} *" : nil
      when 'short_description', 'universal_design', 'universal_design_argumentation', 'localization_additional_info',
           'phone_number', 'flat_number', 'coauthor_email_one', 'coauthor_email_two'
        custom_names[attr]
      end
    end

    # Public: Returns label for custom attributes.
    # For required attributes it adds asterix (*) as it is not automatically added
    # via form builder due to WCAG constraints
    #
    # returns String
    def get_additional_label(attr)
      return '' if additional_attributes.nil? || additional_attributes.empty?
      return '' unless additional_attributes[0][attr.to_s]

      additional_attributes[0][attr.to_s][0]['name']
    end
  end
end
