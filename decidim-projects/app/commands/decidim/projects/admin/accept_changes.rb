# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic to accept changes in many projects at once.
      class AcceptChanges < Rectify::Command
        include Decidim::EmailChecker

        # Public: Initializes the command.
        #
        # component - The component that contains the projects.
        # user      - the Decidim::User that is accepting changes.
        # project_ids - the identifiers of the projects with the changes to be accepted.
        def initialize(component, user, project_ids)
          @component = component
          @user = @current_user = user
          @project_ids = project_ids
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if there are no projects.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless projects.any?

          projects.each do |project|
            transaction do
              coauthor_emails = [project.coauthor_one&.email.presence, project.coauthor_two&.email.presence].compact
              accept_change(project)
              send_notification(project, coauthor_emails)
            end
          end

          broadcast(:ok, projects.first)
        end

        private

        attr_reader :component, :user, :project_ids, :current_user

        # Private: fetch projects
        #
        # returns collection of not yet accepted projects
        def projects
          @projects ||= Decidim::Projects::Project
                         .published
                         .awaits_acceptance
                         .where(component: component)
                         .where(id: project_ids)
        end

        # Private: accepting changes of single project
        #
        # Method maps data from jsonb admin_changes field and
        # process them into project public fields and saves
        # project
        #
        # returns nothing
        def accept_change(project)
          if project.admin_changes&.any?
            project.admin_signature = project.admin_changes['admin_signature']
            update_department(project) if project.admin_changes['project_attrs'] && project.admin_changes['project_attrs']['scope']
            cat_ids = project.admin_changes['categories'].map { |c| c['id'] }
            project.categories = Decidim::Area.active.where(id: cat_ids)
            rec_ids = project.admin_changes['recipients'].map { |c| c['id'] }
            project.recipients = Decidim::AdminExtended::Recipient.where(id: rec_ids )
            project.set_visible_version

            project = Decidim.traceability.update!(
              project,
              changes_author(project),
              parsed_project_attrs(project),
              visibility: "all"
            )
            project.creator_author.update(project.admin_changes['author_data'])
            update_coauthors_data(project)
            # delete files marked for deletion to later accept all that remain
            remove_temp_attachments(project, project.admin_changes['files_to_remove'])
            add_temp_attachments(project)
            project.coauthors_data = project.admin_changes['coauthors_data']
            project.admin_changes = nil # cleaning
            project.save
          end
        end

        def changes_author(project)
          if project.admin_changes && project.admin_changes['whodoit_id'].present?
            Decidim::User.find_by(id: project.admin_changes['whodoit_id']).presence || current_user
          else
            current_user
          end
        end

        # Private: parsing project attributes
        #
        # Fetching project attributes from project.admin_changes and
        # overwriting admin_changes['project_attrs']['scope'] value with Scope
        #
        # returns Hash
        def parsed_project_attrs(project)
          if project_scope(project)
            project.admin_changes['project_attrs'].merge(scope: project_scope(project))
          else
            project.admin_changes['project_attrs'].merge(scope: project.scope)
          end
        end

        # Private: updating current_department
        #
        # returns nothing
        def update_department(project)
          scope = project_scope(project)
          return unless scope
          return unless scope.department

          department = scope.department
          # update current department
          if department != project.current_department
            project.current_department_id = department.id
            project.department_assignments.create(department: department)
          end
        end

        # Private: fetching scope from projecy.admin_changes
        #
        # returns Object - Scope or nil
        def project_scope(project)
          return unless project.admin_changes['project_attrs']['scope']

          Decidim::Scope.find_by(id: project.admin_changes['project_attrs']['scope']['id'])
        end


        def add_temp_attachments(project)
          project.attachments.where(:temporary_file=>true).update_all(:temporary_file=>false)
        end
        def remove_temp_attachments(project, files_to_remove)
          return if files_to_remove.blank?

          if files_to_remove.include?('internal_documents')
            project.internal_documents.where(id: files_to_remove['internal_documents']).delete_all
          end
          if files_to_remove.include?('endorsements')
            project.endorsements.where(id: files_to_remove['endorsements']).delete_all
          end
          if files_to_remove.include?('consents')
            project.consents.where(id: files_to_remove['consents']).delete_all
          end
          if files_to_remove.include?('files')
            project.files.where(id: files_to_remove['files']).delete_all
          end
          if files_to_remove.include?('implementation_photos')
            project.implementation_photos.where(id: files_to_remove['implementation_photos']).destroy_all
          end
        end

        # Private: Sending notifications to users about updating project
        #
        # returns nothing
        def send_notification(project, coauthor_emails)
          project.reload
          return if project.any_draft?

          mail_template = Decidim::AdminExtended::MailTemplate.find_by(system_name: 'admin_edition_project_email_template')
          Decidim::Projects::TemplatedMailerJob.perform_later(project, project.creator_author, mail_template)

          project.coauthors.each do |user|
            mail_template = if user.email && coauthor_emails.include?(user.email)
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

            if mail_template&.filled_in?
              Decidim::Projects::TemplatedMailerJob.perform_later(project, user, mail_template)
            end
          end
        end

        # Private: update coauthors data
        #
        # Method iterates over two sets od coauthors data.
        # For :email different then then email of the user, method unattach coauthor
        # and adds new one that matches new email data.
        # For :email matching user data, method updates coauthor data.
        # In the end Method clears coauthors_data in project
        #
        # returns nothing
        def update_coauthors_data(project)
          for_clear = {}
          project.admin_changes['coauthors_data'].each do |k, v|
            coauthor = project.send("coauthor_#{k}")
            if coauthor && valid_email?(v['email']) && v['email'] != coauthor.email
              # when there is coauthor and email for this coauthor and it is different then it was till now author
              new_coauthor = Decidim::CreateNormalUser.new(v['email'], current_user.organization, v).find_or_create
              if new_coauthor
                new_coauthor.update(author_attributes)
                coauthor_type = if new_coauthor.class.name == 'Decidim::User'
                                  'Decidim::UserBaseEntity'
                                else
                                  new_coauthor.class.name
                                end
                # now we need to overwrite coauthorship with new author id (since author is the first coauthorship)
                coauthorship = project.coauthorships.find_by(author: coauthor)
                coauthorship.update_columns(decidim_author_id: new_coauthor.id, decidim_author_type: coauthor_type, confirmation_status: 'waiting')
              end
            elsif coauthor && valid_email?(v['email']) && v['email'] == coauthor.email
              # when there is a coauthor and there is email and it's the same we change rest of the data
              coauthor.update_columns(v.except('email'))
            elsif coauthor && no_data(v)
              # we set coauthorship to destroy
              index = k == 'one' ? 1 : 2
              for_clear[k] = project.coauthorships.order(created_at: :asc)[index]
            elsif no_data(v)
              # do not create coauthor
            else
              # brand new coauthor
              new_coauthor = Decidim::CreateNormalUser.new(v['email'], current_user.organization, v).find_or_create
              project.add_coauthor(new_coauthor, coauthor: true) if new_coauthor
            end
          end
          # clearing, so the values from actual authors can be set for edit forms
          # project.update_column('coauthors_data', {})
          # project.admin_changes['coauthors_data'] = {}
          # clearing coauthorships
          if for_clear.any?
            for_clear.each do |k, v|
              # if coauthor was empty, becouse of no_data(v) - empty values from form
              next unless v

              v.destroy
            end
          end
          # project.save
        end

        def no_data(v)
          v['email'].blank? && v['first_name'].blank? && v['last_name'].blank? &&
            v['phone_number'].blank? && v['street'].blank? && v['street_number'].blank? &&
            v['flat_number'].blank? && v['zip_code'].blank? && v['city'].blank?
        end
      end
    end
  end
end
