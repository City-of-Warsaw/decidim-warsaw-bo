# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Project in admin panel.
      class ProjectForm < Decidim::Projects::ProjectWizardCreateStepForm
        include Decidim::AttachmentAttributes

        attribute :evaluator
        attribute :state
        attribute :offensive, Boolean

        ##################
        # user data fields
        attribute :first_name, String
        attribute :last_name, String
        attribute :gender, String
        attribute :phone_number, String
        attribute :email, String
        attribute :coauthor1_email, String
        attribute :coauthor2_email, String
        attribute :signed_by_coauthor1, Boolean
        attribute :signed_by_coauthor2, Boolean

        # address fields
        attribute :street, String
        attribute :street_number, String
        attribute :flat_number, String
        attribute :zip_code, String
        attribute :city, String

        # agreements fields
        attribute :show_author_name, GraphQL::Types::Boolean
        attribute :inform_author_about_implementations, GraphQL::Types::Boolean
        attribute :email_on_notification, GraphQL::Types::Boolean

        ##################
        # coauthors fields
        ['1', '2'].each do |i|
          # user data
          attribute "coauthor#{i}_first_name", String
          attribute "coauthor#{i}_last_name", String
          attribute "coauthor#{i}_gender", String
          attribute "coauthor#{i}_phone_number", String
          # user address
          attribute "coauthor#{i}_street", String
          attribute "coauthor#{i}_street_number", String
          attribute "coauthor#{i}_flat_number", String
          attribute "coauthor#{i}_zip_code", String
          attribute "coauthor#{i}_city", String
          # agreements
          attribute "coauthor#{i}_show_author_name", GraphQL::Types::Boolean
          attribute "coauthor#{i}_inform_author_about_implementations", GraphQL::Types::Boolean
          attribute "coauthor#{i}_email_on_notification", GraphQL::Types::Boolean
        end

        ###################
        # additional fields
        attribute :remarks, String
        attribute :unreadable, Boolean
        attribute :signed_by_author, Boolean
        attribute :no_scope_selected, Boolean
        attribute :contractors_and_costs, String
        attribute :budget_description, String

        attribute :implementation_on_main_site, Boolean
        attribute :is_paper, Boolean
        ###################
        # additional fields for temporary file handling

        attribute :to_remove_internal_documents, Array
        attribute :to_remove_endorsements, Array
        attribute :to_remove_consents, Array
        attribute :to_remove_files, Array
        attribute :to_remove_implementation_photos, Array

        attribute :to_add_internal_documents, Array
        attribute :to_add_endorsements, Array
        attribute :to_add_consents, Array
        attribute :to_add_files, Array
        attribute :to_add_implementation_photos, Array


        validates :title, presence: true

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super
          if model.admin_changes && model.admin_changes.any?
            map_admin_changes(model)
          else
            # user data for validation
            # creator = model.creator_author
            # admin handling things
            self.evaluator = model.evaluator
            self.state = model.state

            self.first_name = model.first_name
            self.last_name = model.last_name
            self.gender = model.gender
            self.phone_number = model.phone_number
            self.email = model.email
            # address
            self.street = model.street
            self.street_number = model.street_number
            self.flat_number = model.flat_number
            self.zip_code = model.zip_code
            self.city = model.city
            # agreements
            self.show_author_name = model.show_author_name
            self.inform_author_about_implementations = model.inform_author_about_implementations
            self.email_on_notification = model.email_on_notification
            # additional fields
            self.remarks = model.remarks
            self.unreadable = model.unreadable
            self.is_paper = model.is_paper
            self.implementation_on_main_site = model.implementation_on_main_site

            self.coauthor1_first_name = model.coauthor1_first_name
            self.coauthor1_last_name = model.coauthor1_last_name
            self.coauthor1_gender = model.coauthor1_gender
            self.coauthor1_phone_number = model.coauthor1_phone_number
            self.coauthor1_email = model.coauthor1_email
            self.coauthor1_street = model.coauthor1_street
            self.coauthor1_street_number = model.coauthor1_street_number
            self.coauthor1_flat_number = model.coauthor1_flat_number
            self.coauthor1_zip_code = model.coauthor1_zip_code
            self.coauthor1_city = model.coauthor1_city
            self.coauthor1_show_author_name = model.coauthor1_show_author_name
            self.coauthor1_inform_author_about_implementations = model.coauthor1_inform_author_about_implementations
            self.coauthor1_email_on_notification = model.coauthor_one.email_on_notification if model.coauthor_one

            self.coauthor2_first_name = model.coauthor2_first_name
            self.coauthor2_last_name = model.coauthor2_last_name
            self.coauthor2_gender = model.coauthor2_gender
            self.coauthor2_phone_number = model.coauthor2_phone_number
            self.coauthor2_email = model.coauthor2_email
            self.coauthor2_street = model.coauthor2_street
            self.coauthor2_street_number = model.coauthor2_street_number
            self.coauthor2_flat_number = model.coauthor2_flat_number
            self.coauthor2_zip_code = model.coauthor2_zip_code
            self.coauthor2_city = model.coauthor2_city
            self.coauthor2_show_author_name = model.coauthor2_show_author_name
            self.coauthor2_inform_author_about_implementations = model.coauthor2_inform_author_about_implementations
            self.coauthor2_email_on_notification = model.coauthor_two.email_on_notification if model.coauthor_two

            if check_temp_files_by_type(model, 'internal_documents','files_to_remove')
              self.to_remove_internal_documents = model.admin_changes['files_to_remove']['internal_documents']
            end
            if check_temp_files_by_type(model, 'endorsements','files_to_remove')
              self.to_remove_endorsements = model.admin_changes['files_to_remove']['endorsements']
            end
            if check_temp_files_by_type(model, 'consents','files_to_remove')
              self.to_remove_consents = model.admin_changes['files_to_remove']['consents']
            end
            if check_temp_files_by_type(model, 'files','files_to_remove')
              self.to_remove_files = model.admin_changes['files_to_remove']['files']
            end
            if check_temp_files_by_type(model, 'implementation_photos','files_to_remove')
              self.to_remove_implementation_photos = model.admin_changes['implementation_photos']['files']
            end


            if check_temp_files_by_type(model, 'internal_documents','files_to_add')
              self.to_add_internal_documents = Decidim::Projects::InternalDocument.where(id: model.admin_changes['files_to_add']['internal_documents'])
            end
            if check_temp_files_by_type(model, 'endorsements','files_to_add')
              self.to_add_endorsements = Decidim::Projects::Endorsement.where(id: model.admin_changes['files_to_add']['endorsements'])
            end
            if check_temp_files_by_type(model, 'consents','files_to_add')
              self.to_add_consents = Decidim::Projects::Consent.where(id: model.admin_changes['files_to_add']['consents'])
            end
            if check_temp_files_by_type(model, 'files','files_to_add')
              self.to_add_files = Decidim::Projects::VariousFile.where(id: model.admin_changes['files_to_add']['files'])
            end
            if check_temp_files_by_type(model, 'implementation_photos','files_to_add')
              self.to_add_implementation_photos = Decidim::Projects::ImplementationPhoto.where(id: model.admin_changes['files_to_add']['files'])
            end

          end
        end

        # public method mapping changes for the update view if they were added
        #
        # changes are written in a below matter:
        #
        # admin_changes: {
        #   project_attrs: handled_project_attributes,
        #   author_data: author_attributes,
        #   coauthors_data: coauthors_attributes,
        #   whodoit: current_user,
        #   admin_signature: current_user.admin_comment_name,
        #   categories: form.assigned_categories,
        #   recipients: form.recipients
        # }
        def map_admin_changes(model)
          # mapping: project_attrs: handled_project_attributes
          self.title = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['title'] : model.title
          self.body = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['body'] : model.body
          self.short_description = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['short_description'] : model.short_description
          self.universal_design = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['universal_design'] : model.universal_design
          self.universal_design_argumentation = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['universal_design_argumentation'] : model.universal_design_argumentation
          self.justification_info = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['justification_info'] : model.justification_info
          self.no_scope_selected = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['no_scope_selected'] : model.no_scope_selected
          self.scope_id = (model.admin_changes['project_attrs'].any? && model.admin_changes['project_attrs']['scope']) ? model.admin_changes['project_attrs']['scope']['id'] : model.decidim_scope_id

          self.potential_recipient_ids = model.admin_changes['recipients'].any? ? model.admin_changes['recipients'].map{ |r| r['id'] } : model.recipients.any? ? model.recipients.map(&:id) : []
          self.custom_recipients = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['custom_recipients'] : model.custom_recipients
          self.category_ids = map_admin_changes_categories(model)
          self.custom_categories = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['custom_categories'] : model.custom_categories

          self.localization_info = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['localization_info'] : model.localization_info
          self.localization_additional_info = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['localization_additional_info'] : model.localization_additional_info
          self.locations_json = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['locations'].to_json : model.locations.to_json
          self.additional_data = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['additional_data'] : model.additional_data

          self.budget_value = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['budget_value'] : model.budget_value
          self.budget_description = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['budget_description'] : model.budget_description
          self.contractors_and_costs = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['contractors_and_costs'] : model.contractors_and_costs
          self.coauthor1_email = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['coauthor1_email'] : model.coauthor1_email
          self.coauthor2_email = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['coauthor2_email'] : model.coauthor2_email
          self.signed_by_author = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['signed_by_author'] : model.signed_by_author
          self.signed_by_coauthor1 = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['signed_by_coauthor1'] : model.signed_by_coauthor1
          self.signed_by_coauthor2 = model.admin_changes['project_attrs'].any? ? model.admin_changes['project_attrs']['signed_by_coauthor2'] : model.signed_by_coauthor2

          # mapping: author_data: author_attributes
          if model.admin_changes['author_data'] && model.admin_changes['author_data'].any?
            self.first_name = model.admin_changes['author_data']['first_name'].presence || model.first_name
            self.last_name = model.admin_changes['author_data']['last_name'].presence || model.last_name
            self.gender = model.admin_changes['author_data']['gender'].presence || model.gender
            self.phone_number = model.admin_changes['author_data']['phone_number'].presence || model.phone_number
            self.email = model.admin_changes['author_data']['email'].presence || model.email
            # address
            self.street = model.admin_changes['author_data']['street'].presence || model.street
            self.street_number = model.admin_changes['author_data']['street_number'].presence || model.street_number
            self.flat_number = model.admin_changes['author_data']['flat_number'].presence || model.flat_number
            self.zip_code = model.admin_changes['author_data']['zip_code'].presence || model.zip_code
            self.city = model.admin_changes['author_data']['city'].presence || model.city
            # agreements
            self.show_author_name = model.admin_changes['author_data']['show_author_name']
            self.inform_author_about_implementations = model.admin_changes['author_data']['inform_author_about_implementations']
            self.email_on_notification = model.admin_changes['author_data']['email_on_notification']
          end


          if check_temp_files_by_type(model, 'internal_documents','files_to_remove')
            self.to_remove_internal_documents = model.admin_changes['files_to_remove']['internal_documents']
          end
          if check_temp_files_by_type(model, 'endorsements','files_to_remove')
            self.to_remove_endorsements = model.admin_changes['files_to_remove']['endorsements']
          end
          if check_temp_files_by_type(model, 'consents','files_to_remove')
            self.to_remove_consents = model.admin_changes['files_to_remove']['consents']
          end
          if check_temp_files_by_type(model, 'files','files_to_remove')
            self.to_remove_files = model.admin_changes['files_to_remove']['files']
          end
          if check_temp_files_by_type(model, 'implementation_photos','files_to_remove')
            self.to_remove_implementation_photos = model.admin_changes['implementation_photos']['files']
          end


          if check_temp_files_by_type(model, 'internal_documents','files_to_add')
            self.to_add_internal_documents = Decidim::Projects::InternalDocument.where(id: model.admin_changes['files_to_add']['internal_documents'])
          end
          if check_temp_files_by_type(model, 'endorsements','files_to_add')
            self.to_add_endorsements = Decidim::Projects::Endorsement.where(id: model.admin_changes['files_to_add']['endorsements'])
          end
          if check_temp_files_by_type(model, 'consents','files_to_add')
            self.to_add_consents = Decidim::Projects::Consent.where(id: model.admin_changes['files_to_add']['consents'])
          end
          if check_temp_files_by_type(model, 'files','files_to_add')
            self.to_add_files = Decidim::Projects::VariousFile.where(id: model.admin_changes['files_to_add']['files'])
          end
          if check_temp_files_by_type(model, 'implementation_photos','files_to_add')
            self.to_add_implementation_photos = Decidim::Projects::ImplementationPhoto.where(id: model.admin_changes['files_to_add']['files'])
          end

          # mapping: coauthors_data: coauthors_attributes
          if model.admin_changes['coauthors_data'] && model.admin_changes['coauthors_data'].any?
            ['1', '2'].each do |i|
              # coauthor
              self.send("coauthor#{i}_first_name=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['first_name'] : model.send("coauthor_#{i}")&.first_name)
              self.send("coauthor#{i}_last_name=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['last_name'] : model.send("coauthor_#{i}")&.last_name)
              self.send("coauthor#{i}_gender=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['gender'] : model.send("coauthor_#{i}")&.gender)
              self.send("coauthor#{i}_phone_number=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['phone_number'] : model.send("coauthor_#{i}")&.phone_number)
              # coauthor address
              self.send("coauthor#{i}_street=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['street'] : model.send("coauthor_#{i}")&.street)
              self.send("coauthor#{i}_street_number=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['street_number'] : model.send("coauthor_#{i}")&.street_number)
              self.send("coauthor#{i}_flat_number=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['flat_number'] : model.send("coauthor_#{i}")&.flat_number)
              self.send("coauthor#{i}_zip_code=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['zip_code'] : model.send("coauthor_#{i}")&.zip_code)
              self.send("coauthor#{i}_city=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['city'] : model.send("coauthor_#{i}")&.city)
              # coauthor agreements
              self.send("coauthor#{i}_show_author_name=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['show_author_name'] : model.send("coauthor_#{i}")&.show_author_name)
              self.send("coauthor#{i}_inform_author_about_implementations=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['inform_author_about_implementations'] : model.send("coauthor_#{i}")&.inform_author_about_implementations)
              self.send("coauthor#{i}_email_on_notification=", model.admin_changes['coauthors_data'][i] ? model.admin_changes['coauthors_data'][i]['email_on_notification'] : model.send("coauthor_#{i}")&.email_on_notification)
            end
          end
        end


        def check_temp_files_by_type(model, name, type)
          return false if model.admin_changes.blank? || model.admin_changes[type].blank?

          model.admin_changes[type].include?(name)
        end

        def map_admin_changes_categories(model)
          if model.admin_changes['categories'].any?
            model.admin_changes['categories'].map{ |r| r['id'] }
          elsif model.categories.any?
            model.categories.map(&:id)
          else
            []
          end
        end
      end
    end
  end
end
