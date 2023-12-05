# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user creates or updates a customized project form.
      class CreateProjectCustomization < Rectify::Command
        # Public: Initializes the command.
        #
        # form          - A form object with the params.
        # current_user  - current user
        # process       - Participatory Process
        # customization - Decidim::Projects::ProjectCustomization
        def initialize(form, current_user, process, customization)
          @form = form
          @current_user = current_user
          @process = process
          @customization = customization
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Method calls either update or create method for customization
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            if @customization.persisted?
              update_customization
            else
              create_customization
            end

          end

          broadcast(:ok, process)
        end

        private

        attr_reader :form, :process

        # Private: creating customization
        #
        # returns Decidim::Projects::ProjectCustomization
        def create_customization
          @customization = Decidim.traceability.perform_action!(
            :create_customization,
            @process,
            @current_user,
            visibility: "admin-only"
          ) do
            customization = Decidim::Projects::ProjectCustomization.create(customization_attributes.merge(process: process))
            customization
          end
        end

        # Private: updating customization
        #
        # returns Decidim::Projects::ProjectCustomization
        def update_customization
          @customization = Decidim.traceability.perform_action!(
            :update_customization,
            @process,
            @current_user,
            visibility: "admin-only"
          ) do
            customization = Decidim::Projects::ProjectCustomization.update(customization_attributes)
            customization
          end
        end

        # Private: customization attributes
        #
        # returns Hash
        def customization_attributes
          {
            additional_attributes: form.additional_attributes || {},
            # custom_names
            custom_names: {
              title: form.title,
              title_help_text: form.title_help_text,
              title_hint: form.title_hint,
              body: form.body,
              body_help_text: form.body_help_text,
              body_hint: form.body_hint,
              short_description: form.short_description,
              short_description_help_text: form.short_description_help_text,
              short_description_hint: form.short_description_hint,
              universal_design: form.universal_design,
              universal_design_help_text: form.universal_design_help_text,
              universal_design_hint: form.universal_design_hint,
              universal_design_argumentation: form.universal_design_argumentation,
              universal_design_argumentation_help_text: form.universal_design_argumentation_help_text,
              universal_design_argumentation_hint: form.universal_design_argumentation_hint,
              justification_info: form.justification_info,
              justification_info_help_text: form.justification_info_help_text,
              justification_info_hint: form.justification_info_hint,
              category_ids: form.category_ids,
              category_ids_help_text: form.category_ids_help_text,
              category_ids_hint: form.category_ids_hint,
              potential_recipient_ids: form.potential_recipient_ids,
              potential_recipient_ids_help_text: form.potential_recipient_ids_help_text,
              potential_recipient_ids_hint: form.potential_recipient_ids_hint,
              localization_info: form.localization_info,
              localization_info_help_text: form.localization_info_help_text,
              localization_info_hint: form.localization_info_hint,
              localization_additional_info: form.localization_additional_info,
              localization_additional_info_help_text: form.localization_additional_info_help_text,
              localization_additional_info_hint: form.localization_additional_info_hint,
              budget_value: form.budget_value,
              budget_value_help_text: form.budget_value_help_text,
              budget_value_hint: form.budget_value_hint,
              scope_id: form.scope_id,
              scope_id_help_text: form.scope_id_help_text,
              scope_id_hint: form.scope_id_hint,
              coauthor_email_one: form.coauthor_email_one&.downcase,
              coauthor_email_one_help_text: form.coauthor_email_one_help_text,
              coauthor_email_one_hint: form.coauthor_email_one_hint,
              coauthor_email_two: form.coauthor_email_two&.downcase,
              coauthor_email_two_help_text: form.coauthor_email_two_help_text,
              coauthor_email_two_hint: form.coauthor_email_two_hint,
              # user data
              first_name: form.first_name,
              first_name_help_text: form.first_name_help_text,
              first_name_hint: form.first_name_hint,
              last_name: form.last_name,
              last_name_help_text: form.last_name_help_text,
              last_name_hint: form.last_name_hint,
              gender: form.gender,
              gender_help_text: form.gender_help_text,
              gender_hint: form.gender_hint,
              phone_number: form.phone_number,
              phone_number_help_text: form.phone_number_help_text,
              phone_number_hint: form.phone_number_hint,
              email: form.email,
              email_help_text: form.email_help_text,
              email_hint: form.email_hint,
              street: form.street,
              street_help_text: form.street_help_text,
              street_hint: form.street_hint,
              street_number: form.street_number,
              street_number_help_text: form.street_number_help_text,
              street_number_hint: form.street_number_hint,
              flat_number: form.flat_number,
              flat_number_help_text: form.flat_number_help_text,
              flat_number_hint: form.flat_number_hint,
              zip_code: form.zip_code,
              zip_code_help_text: form.zip_code_help_text,
              zip_code_hint: form.zip_code_hint,
              city: form.city,
              city_help_text: form.city_help_text,
              city_hint: form.city_hint
            }
          }
        end
      end
    end
  end
end