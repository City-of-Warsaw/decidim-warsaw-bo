# frozen_string_literal: true

module Decidim
  module Projects::Admin
    module Implementation
      # A command with all the business logic when a user creates a new implementation.
      class CreateImplementation < Rectify::Command
        include Decidim::Projects::CustomAttachmentsMethods

        # Public: Initializes the command.
        def initialize(form, current_user)
          @form = form
          @project = form.project
          @original_status = project.implementation_status
          @current_user = current_user
          @documents = []
          @attached_to = @project
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the implementation.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless project

          transaction do
            create_implementation
            build_implementation_photos_for(project)
            remove_attachments(project)
          end

          notify_users if update_is_notifiable?

          broadcast(:ok)
        end

        private

        attr_reader :form, :project, :current_user, :implementation

        # Prevent PaperTrail from creating an additional version
        # in the implementation multi-step creation process (step 1: create)
        #
        # A first version will be created in step 4: publish
        # for diff rendering in the implementation version control
        def create_implementation
          @project.set_visible_version
          @implementation = Decidim.traceability.perform_action!(
            :update_implementation,
            @project,
            @current_user,
            visibility: "admin-only"
          ) do
            implementation = @project.implementations.create(implementation_attributes)
            @project.update(project_attributes)
            @project.save
            implementation
          end
        end

        def implementation_attributes
          {
            project: @project,
            body: form.implementation_body,
            implementation_date: form.implementation_date,
            user: current_user,
            update_data: project_attributes.merge(photos: image_attributes)
          }
        end

        # Private method checking if update provides data that should trigger notifications
        # - Implementation body is present OR
        # - Implementation status was changed
        #
        # Returns Boolean
        def update_is_notifiable?
          @implementation.persisted? && (form.implementation_body.present? || form.implementation_status != @original_status)
        end

        def notify_users
          Decidim::Projects::ImplementationMailerJob.perform_later(implementation)
        end

        def image_attributes
          ip = []
          return {} unless @form.respond_to?(:add_implementation_photos)
          return {} if @form.add_implementation_photos.none?

          @form.add_implementation_photos.each do |file|
            processed_name = file.original_filename.gsub(' ', '').gsub('-', '').gsub('_', '')
            image_alt = @form.add_implementation_photos_alt[processed_name.to_sym].presence || ''
            ip << [file.original_filename, image_alt]
          end
          ip
        end

        def project_attributes
          @current_user.ad_admin? ? main_attributes.merge(admin_params) : main_attributes
        end

        def main_attributes
          {
            implementation_status: form.implementation_status,
            producer_list: form.producer_list,
            factual_budget_value: form.factual_budget_value
          }
        end

        def admin_params
          {
            implementation_on_main_site: form.implementation_on_main_site,
            implementation_on_main_site_slider: form.implementation_on_main_site_slider
          }
        end
      end
    end
  end
end
