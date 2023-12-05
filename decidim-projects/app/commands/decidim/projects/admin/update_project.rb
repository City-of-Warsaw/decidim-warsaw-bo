# # frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user updates a project.
      class UpdateProject < Rectify::Command
        include ::Decidim::AttachmentMethods
        include Decidim::Projects::CustomAttachmentsMethods
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # project      - the proposal to update.
        # subaction    - String
        def initialize(form, project, subaction = nil)
          @form = form
          @project = project
          @attached_to = project
          @with_attachments = form.respond_to?(:add_documents)
          @documents = []
          @subaction = subaction
          @coauthors_emails = [project.coauthor_one&.email.presence, project.coauthor_two&.email.presence].compact
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid if attachments are invalid.
        #
        # Method allows for classic updating project or
        # temporary updating project, that needs to be accepted.
        # With proper value in variable @subaction temporary update can be
        # instantly followed by acceptance of the temporaly changes
        #
        # Returns nothing.
        def call
          Rails.logger.info "UPDATE_PROJEKCT"
          return broadcast(:invalid) if form.invalid?

          # delete_attachment(form.attachment) if delete_attachment?
          #
          # if process_attachments?
          #   @project.attachments.destroy_all
          #
          #   build_attachment
          #   return broadcast(:invalid) if attachment_invalid?
          # end

          # if @with_attachments
          #   build_attachments
          #   return broadcast(:invalid) if attachments_invalid?
          # end

          build_internal_documents_for(nil)
          build_endorsements_for(nil)
          build_consents_for(nil)
          build_files_for(nil)
          return broadcast(:invalid) if endorsements_invalid?(project: project, max_files_num: nil) ||
            files_invalid?(project: project, max_files_num: nil) ||
            consents_invalid?(project: project, max_files_num: nil) ||
            internal_documents_invalid?


          transaction do
            if (project.any_draft? || current_user.ad_admin? || current_user.ad_coordinator?) && @subaction != 'save-accept'
              # projects, that can be updated
              # drafts - with invisible version
              # when update is made by admin or coordinator
              update_project
              remove_attachments(@project)

              send_notification(@project)
            else
              # projects, that can not be be updated
              # and need confirmation

              temporary_update_project

              if @subaction == 'save-accept'
                # and accept -> current_user is the actor of the action, and admin_changes are cleared
                Decidim::Projects::Admin::AcceptChanges.call(@project.component, @current_user, [@project.id])
                remove_attachments(@project)
                send_notification(@project)
                remove_attachments(@project)
              end
            end

          end

          broadcast(:ok, project)
        end

        private

        attr_reader :form, :project, :attachment, :gallery

        # Private: update project
        #
        # Method updates project and assigns current users signature as author of changes.
        # It creates new version and ActionLog
        #
        # returns nothing
        def update_project
          @project.set_admin_signature(current_user)
          # after project was published only admin can freely change scopes
          # for department forwarding coordinators have special action and list of available departments
          update_department(@project) if (project.any_draft? || current_user.ad_admin?) && form.scope && form.scope != @project.scope
          @project.categories = form.assigned_categories
          @project.recipients = form.recipients
          @project.set_visible_version unless @project.any_draft?

          @project = Decidim.traceability.update!(
            @project,
            current_user,
            handled_project_attributes,
            visibility: "all"
          )

          build_internal_documents_for(@project)
          build_endorsements_for(@project)
          build_consents_for(@project)
          build_files_for(@project)

          update_creator_data
          update_coauthors_data

          @project.save
        end

        # Private: update author data
        #
        # returns nothing
        def update_creator_data
          @project.author_data = author_attributes
          @project.creator_author.update(email_on_notification: form.email_on_notification)
        end

        # Private: update coauthors data
        # returns nothing
        def update_coauthors_data
          @project.coauthor1_data = coauthors_attributes[0]
          @project.coauthor_one.update_column(:email_on_notification, form.coauthor1_email_on_notification) if @project.coauthor_one

          @project.coauthor2_data = coauthors_attributes[1]
          @project.coauthor_two.update_column(:email_on_notification, form.coauthor2_email_on_notification) if @project.coauthor_two
        end

        def no_data(v)
          v[:email].blank? && v[:first_name].blank? && v[:last_name].blank? &&
            v[:phone_number].blank? && v[:street].blank? && v[:street_number].blank? &&
            v[:flat_number].blank? && v[:zip_code].blank? && v[:city].blank?
        end

        # Private: update current department i project
        #
        # returns nothing
        def update_department(project)
          return unless form.scope.department

          department = form.scope.department
          # update current department
          if department != project.current_department
            project.current_department_id = department.id
            project.department_assignments.create(department: department)
          end
        end

        # Private: adding scope to attributes if it was present in form and current user is admin (only admin can change scope)
        #
        # returns Hash
        def handled_project_attributes
          (project.any_draft? || current_user.ad_admin?) && form.scope ? project_attributes.merge(scope: form.scope) : project_attributes
        end

        # Private: project attributes
        #
        # returns Hash
        def project_attributes
          {
            # default attributes
            title: form.title,
            body: form.body,
            # custom
            short_description: form.short_description,
            custom_categories: form.custom_categories,
            custom_recipients: form.custom_recipients,
            universal_design: form.universal_design,
            universal_design_argumentation: form.universal_design_argumentation,
            justification_info: form.justification_info,
            no_scope_selected: form.no_scope_selected,
            localization_info: form.localization_info,
            localization_additional_info: form.localization_additional_info,
            locations: form.locations_data,
            budget_value: form.budget_value,
            budget_description: form.budget_description,
            contractors_and_costs: form.contractors_and_costs,
            coauthor_email_one: form.coauthor1_email&.downcase,
            coauthor_email_two: form.coauthor2_email&.downcase,
            signed_by_coauthor1: form.signed_by_coauthor1,
            signed_by_coauthor2: form.signed_by_coauthor2,
            implementation_on_main_site: form.implementation_on_main_site,
            signed_by_author: form.signed_by_author,
            coauthors_data: coauthors_attributes,
            offensive: form.offensive.nil? ? false : form.offensive
          }
        end

        # private method
        #
        # returns Object - Organization from current_user
        def organization
          @organization ||= current_user.organization
        end

        # Private: author attributes
        #
        # returns Hash
        def author_attributes
          {
            email: form.email,
            first_name: form.first_name,
            last_name: form.last_name,
            gender: form.gender,
            phone_number: form.phone_number,
            street: form.street,
            street_number: form.street_number,
            flat_number: form.flat_number,
            zip_code: form.zip_code,
            city: form.city,
            # agreements
            show_author_name: ActiveModel::Type::Boolean.new.cast(form.show_author_name),
            inform_author_about_implementations: ActiveModel::Type::Boolean.new.cast(form.inform_author_about_implementations),
          }
        end

        # Private: return coauthors attributes
        #
        # returns Array of hash
        def coauthors_attributes
          ['1', '2'].map do |i|
            h = {
              email: form.send("coauthor#{i}_email")&.downcase&.strip,
              first_name: form.send("coauthor#{i}_first_name"),
              last_name: form.send("coauthor#{i}_last_name"),
              gender: form.send("coauthor#{i}_gender"),
              phone_number: form.send("coauthor#{i}_phone_number"),
              street: form.send("coauthor#{i}_street"),
              street_number: form.send("coauthor#{i}_street_number"),
              flat_number: form.send("coauthor#{i}_flat_number"),
              zip_code: form.send("coauthor#{i}_zip_code"),
              city: form.send("coauthor#{i}_city"),
              # agreements
              show_author_name: ActiveModel::Type::Boolean.new.cast(form.send("coauthor#{i}_show_author_name")),
              inform_author_about_implementations: ActiveModel::Type::Boolean.new.cast(form.send("coauthor#{i}_inform_author_about_implementations"))
            }
            h.values.select(&:present?).any? ? h : {}
          end
        end

        # Private: temporal update
        #
        # Method saves project data in jsonb fields.
        # Users with proper permissions can later save project with this temporal data
        #
        # returns Project
        def temporary_update_project
          @project = Decidim.traceability.perform_action!(
            :changes_for_acceptance,
            @project,
            current_user,
            visibility: "admin-only"
          ) do
            @project.update_columns(
              admin_changes: {
                project_attrs: handled_project_attributes,
                author_data: author_attributes,
                coauthors_data: coauthors_attributes,
                whodoit_id: current_user.id,
                admin_signature: current_user.admin_comment_name,
                categories: form.assigned_categories,
                recipients: form.recipients,
                files_to_remove: attachments_to_remove(@project),
                files_to_add: attachments_save_and_list
              }
            )
            @project
          end
        end

        def attachments_save_and_list
          temp_files = {}
          @endorsements.map(&:save)
          @endorsements.map{|element| element.update(temporary_file: true)}
          temp_files.merge!(endorsements: @form.to_add_endorsements) if @form.to_add_endorsements.any?
          temp_files.merge!(endorsements: @endorsements.pluck(:id)) if @endorsements.any?

          @internal_documents.map(&:save)
          @internal_documents.map{|element| element.update(temporary_file: true)}


          temp_files.merge!(internal_documents: @form.to_add_internal_documents) if @form.to_add_internal_documents.any?
          temp_files.merge!(internal_documents: @internal_documents.pluck(:id)) if @internal_documents.any?

          @consents.map(&:save)
          @consents.map{|element| element.update(temporary_file: true)}

          temp_files.merge!(consents: @form.to_add_consents) if @form.to_add_consents.any?
          temp_files.merge!(consents: @consents.pluck(:id)) if @consents.any?

          @files.map(&:save)
          @files.map{|element| element.update(temporary_file: true)}
          temp_files.merge!(files: @form.to_add_files) if @form.to_add_files.any?
          temp_files.merge!(files: @files.pluck(:id)) if @files.any?

          temp_files
        end

        # Private: send message to project authors
        #
        # returns nothing
        def send_notification(project)
          project.reload
          return if project.any_draft?

          project.authors.each do |user|
            next unless user.inform_about_admin_changes

            mail_template = if user == project.creator_author
                              # set mail_template only if creator was not changed,
                              # in case he was changed, he gets a different mail earlier
                              if form.email == user.email
                                Decidim::AdminExtended::MailTemplate.find_by(system_name: 'admin_edition_project_email_template')
                              end
                            else
                              if user.email && @coauthors_emails.include?(user.email)
                                # old coauthor
                                if project.coauthorships.confirmed.find_by(author: user)
                                  Decidim::AdminExtended::MailTemplate.find_by(system_name: 'admin_edition_project_email_template')
                                end
                              else
                                # new coauthor
                                if user.sign_in_count.zero?
                                  # user that was created by system
                                  Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthor_invitation_email_template')
                                else
                                  Decidim::AdminExtended::MailTemplate.find_by(system_name: 'coauthorship_confirmation_email_template')
                                end
                              end
                            end
            if mail_template&.filled_in?
              Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
            end
          end
        end
      end
    end
  end
end
