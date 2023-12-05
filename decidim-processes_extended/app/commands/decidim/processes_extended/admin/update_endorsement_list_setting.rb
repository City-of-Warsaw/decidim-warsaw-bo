# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    module Admin
      # A command with all the business logic when a wants to update endorsement list setting update.
      class UpdateEndorsementListSetting < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # current_user - current user
        # endorsement_list_setting - the endorsement_list_setting to update.
        def initialize(endorsement_list_setting, form, current_user)
          @form = form
          @endorsement_list_setting = endorsement_list_setting
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid,
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_settings

          broadcast(:ok)
        end

        private

        attr_reader :form, :endorsement_list_setting, :current_user

        def update_settings
          Decidim.traceability.perform_action!(
            :update_endorsement_list_setting,
            endorsement_list_setting,
            current_user,
            visibility: "admin-only"
          ) do
            endorsement_list_setting.update(attributes)
          end
        end

        def attributes
          {
            header_description: form.header_description,
            footer_description: form.footer_description
          }.merge(file_data)
        end

        def file_data
          if form.image_header.present?
            { image_header: form.image_header }
          else
            {}
          end
        end

      end
    end
  end
end
