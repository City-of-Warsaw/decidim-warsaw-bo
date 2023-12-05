# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A command with all the business logic when a user creates a new project.
      class CreateProject < Rectify::Command
        include ::Decidim::AttachmentMethods
        include Decidim::Projects::CustomAttachmentsMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
          @documents = []
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        # - :invalid if the attachments are invalid
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          build_internal_documents_for(nil)
          build_endorsements_for(nil)
          build_consents_for(nil)
          build_files_for(nil)
          return broadcast(:invalid) if endorsements_invalid?(max_files_num: nil) ||
                                              consents_invalid?(max_files_num: nil) ||
                                              files_invalid?(max_files_num: nil) ||
                                              internal_documents_invalid?

          create_project
          broadcast(:ok, project)
        end

        private

        attr_reader :form, :project, :attachment, :gallery

        # Private: creating project
        #
        # Method does not create project version,
        # creates ActionLog.
        # It is responsible for finding or creating User instance and assigning
        # it as author and updating it's data if it was provided.
        # Method finds or create coauthors and assign them do the project with
        # status 'waiting'
        #
        # returns project
        def create_project
          PaperTrail.request(enabled: false) do
            @project = Decidim.traceability.perform_action!(
              :create,
              Decidim::Projects::Project,
              @current_user,
              visibility: "admin-only"
            ) do
              project = Decidim::Projects::Project.create(project_attributes)

              author = find_or_create_author
              ProjectAuthorsManager.new(project).add_author(author) if author

              create_coauthors(project)

              # clearing, so the values from actual authors can be set for edit forms
              project.coauthors_data = {}

              build_internal_documents_for(project)
              build_endorsements_for(project)
              build_consents_for(project)
              build_files_for(project)

              project.save!
              project
            end
          end
          # associations
          @project.categories = form.assigned_categories
          @project.recipients = form.recipients
          @project.users << current_user
          @attached_to = @project
        end

        # Private: find or create author
        #
        # Method calls command finding or creating user with given author data
        #
        # returns Object - Decidim::User or Decidim::Projects::SimpleUser
        def find_or_create_author
          Decidim::CreateNormalUser.new(form.email, form.current_organization, author_attributes).find_or_create
        end

        # Private: project attributes
        #
        # returns Hash
        def project_attributes
          {
            evaluator: current_user,
            # default
            state: Decidim::Projects::Project::ADMIN_POSSIBLE_STATES[0],
            is_paper: true,
            component: form.component,
            edition_year: form.component.participatory_space&.edition_year,
            # custom
            title: form.title,
            body: form.body,
            short_description: form.short_description,
            custom_categories: form.custom_categories,
            custom_recipients: form.custom_recipients,
            universal_design: form.universal_design,
            universal_design_argumentation: form.universal_design_argumentation,
            justification_info: form.justification_info,
            no_scope_selected: form.no_scope_selected,
            scope: form.scope,
            localization_info: form.localization_info,
            localization_additional_info: form.localization_additional_info,
            locations: form.locations_data,
            budget_value: form.budget_value,
            coauthor_email_one: form.coauthor1_email&.downcase,
            coauthor_email_two: form.coauthor2_email&.downcase,
            signed_by_coauthor1: form.signed_by_coauthor1,
            signed_by_coauthor2: form.signed_by_coauthor2,
            signed_by_author: form.signed_by_author,
            author_data: author_data_for_project,
            coauthor1_data: coauthors_attributes[0],
            coauthor2_data: coauthors_attributes[1]
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

        # Private: author attributes
        #
        # returns Hash
        def author_attributes
          {
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
            email_on_notification: form.email_on_notification
          }
        end

        def author_data_for_project
          author_attributes.merge({
                                    show_author_name: form.show_author_name,
                                    inform_author_about_implementations: form.inform_author_about_implementations,
                                  })
        end

        # Private: find or create author
        #
        # Method calls command finding or creating user with given coauthors data.
        # It skips calling command if there is no data given
        #
        # returns Object - Decidim::User or Decidim::Projects::SimpleUser
        def create_coauthors(project)
          coauthors_attributes.each do |k|
            next if no_data?(k)

            ProjectAuthorsManager.new(project).create_coauthor(k[:email], k)
          end
        end

        # Private: checking if coauthor params are not empty
        #
        # Params:
        # - v - Hash
        #
        # returns Boolean
        def no_data?(v)
          v[:email].blank? && v[:first_name].blank? && v[:last_name].blank? &&
            v[:phone_number].blank? && v[:street].blank? && v[:street_number].blank? &&
            v[:flat_number].blank? && v[:zip_code].blank? && v[:city].blank?
        end
      end
    end
  end
end
