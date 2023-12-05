# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user creates a new appeal.
      class CreateAppeal < Rectify::Command
        include ::Decidim::MultipleAttachmentsMethods

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # current_user - The current user.
        def initialize(form, current_user)
          @form = form
          @project = form.project
          @current_user = current_user
          @documents = []
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the appeal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid if there is no project.
        # - :invalid if attachments are invalid.
        # - :invalid if project has appeal already
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless project
          return broadcast(:invalid) if project.appeal


          build_attachments
          return broadcast(:invalid) if attachments_invalid?

          transaction do
            create_appeal
            create_attachments if process_attachments?
            update_project
          end

          broadcast(:ok, @appeal)
        end

        private

        attr_reader :form, :project, :current_user

        # Prevent PaperTrail from creating an additional version
        # in the appeal multi-step creation process (step 1: create)
        #
        # Creates ActionLog
        #
        # returns Appeal
        def create_appeal
          PaperTrail.request(enabled: false) do
            @appeal = Decidim.traceability.perform_action!(
              :create_appeal,
              @project,
              @current_user,
              visibility: 'admin-only'
            ) do
              appeal = Decidim::Projects::Appeal.new(
                appeal_attributes
              )
              appeal.save!
              appeal
            end
          end
          @attached_to = @appeal
        end

        # Private: update project
        #
        # Method updates project's verification status
        # and add current user to projects associacion :users
        #
        # Creates ActionLog
        #
        # returns nothing
        def update_project
          @project = Decidim.traceability.update!(
            @project,
            current_user,
            project_attributes,
            visibility: 'admin-only'
          )
          project.users << current_user unless project.users.pluck(:id).include?(current_user.id)
        end

        # Private: appeal attributes
        #
        # returns Hash
        def appeal_attributes
          {
            project: @project,
            body: form.body,
            time_of_submit: form.time_of_submit,
            author: current_user,
            is_paper: true
          }
        end

        # Private: project attributes
        #
        # returns Hash
        def project_attributes
          {
            evaluator: choose_verificator, # signing to appeal current user
            verification_status: new_verification_status
          }
        end


        def choose_verificator
          if current_user.ad_coordinator? || current_user.ad_admin?
            current_user
          else
            nil
          end
        end
        # when admin or coordinator create appeal, acceptance is not required
        def new_verification_status
          if current_user.ad_coordinator? || current_user.ad_admin?
            'appeal_waiting'
          else
            'appeal_draft'
          end
        end
      end
    end
  end
end
