# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to accept changes in project that were added by user with no publishing permissions in admin panel.
      class ChangesProjectForm < Decidim::Projects::Admin::ProjectForm
        attribute :project

        mimic :project

        # Public: maps project fields into FormObject attributes
        def map_model(model)
          super
          # mapping from admin changes
          self.project = model
          # project itself
          self.title = model.admin_changes['project_attrs']['title']
          self.body = model.admin_changes['project_attrs']['body']
          self.scope_id = model.admin_changes['project_attrs']['scope'] if model.admin_changes['project_attrs']['scope']
          self.potential_recipient_ids = model.admin_changes['recipients'] if model.admin_changes['recipients'].any?
          if model.admin_changes['project_attrs']['custom_recipients'].present?
            self.potential_recipient_ids_other = 'other'
          end
          if model.admin_changes['categories'].any?
            self.category_ids = model.admin_changes['project_attrs']['categories']
          end
          self.category_ids_other = 'other' if model.admin_changes['project_attrs']['custom_categories'].present?
          self.locations_json = model.admin_changes['project_attrs']['locations'].to_json
          self.additional_data = model.admin_changes['project_attrs']['additional_data']
          # author
          self.first_name = model.admin_changes['author_data']['first_name'] if model.admin_changes['author_data'].any?
          self.last_name = model.admin_changes['author_data']['last_name'] if model.admin_changes['author_data'].any?
          self.gender = model.admin_changes['author_data']['gender'] if model.admin_changes['author_data'].any?
          if model.admin_changes['author_data'].any?
            self.phone_number = model.admin_changes['author_data']['phone_number']
          end
          self.email = model.admin_changes['author_data']['email'] if model.admin_changes['author_data'].any?
          # author address
          self.street = model.admin_changes['author_data']['street'] if model.admin_changes['author_data'].any?
          if model.admin_changes['author_data'].any?
            self.street_number = model.admin_changes['author_data']['street_number']
          end
          if model.admin_changes['author_data'].any?
            self.flat_number = model.admin_changes['author_data']['flat_number']
          end
          self.zip_code = model.admin_changes['author_data']['zip_code'] if model.admin_changes['author_data'].any?
          self.city = model.admin_changes['author_data']['city'] if model.admin_changes['author_data'].any?
          # author agreements
          if model.admin_changes['author_data'].any?
            self.show_my_name = model.admin_changes['author_data']['show_my_name']
          end
          if model.admin_changes['author_data'].any?
            self.inform_me_about_proposal = model.admin_changes['author_data']['inform_me_about_proposal']
          end
          if model.admin_changes['author_data'].any?
            self.email_on_notification = model.admin_changes['author_data']['email_on_notification']
          end
          %w[one two].each do |i|
            next unless model.admin_changes['coauthors_data']
            next unless model.admin_changes['coauthors_data'][i]

            # coauthor
            send("coauthor_#{i}_first_name=", model.admin_changes['coauthors_data'][i]['first_name'])
            send("coauthor_#{i}_last_name=", model.admin_changes['coauthors_data'][i]['last_name'])
            send("coauthor_#{i}_gender=", model.admin_changes['coauthors_data'][i]['gender'])
            send("coauthor_#{i}_phone_number=", model.admin_changes['coauthors_data'][i]['phone_number'])
            send("coauthor_email_#{i}=", model.admin_changes['coauthors_data'][i]['email'])
            # coauthor address
            send("coauthor_#{i}_street=", model.admin_changes['coauthors_data'][i]['street'])
            send("coauthor_#{i}_street_number=", model.admin_changes['coauthors_data'][i]['street_number'])
            send("coauthor_#{i}_flat_number=", model.admin_changes['coauthors_data'][i]['flat_number'])
            send("coauthor_#{i}_zip_code=", model.admin_changes['coauthors_data'][i]['zip_code'])
            send("coauthor_#{i}_city=", model.admin_changes['coauthors_data'][i]['city'])
            # coauthor agreements
            send("coauthor_#{i}_show_my_name=", model.admin_changes['coauthors_data'][i]['show_my_name'])
            send("coauthor_#{i}_inform_me_about_proposal=", model.admin_changes['coauthors_data'][i]['inform_me_about_proposal'])
            send("coauthor_#{i}_email_on_notification=", model.admin_changes['coauthors_data'][i]['email_on_notification'])
          end
          # additional fields
          self.remarks = model.admin_changes['project_attrs']['remarks']
          self.unreadable = model.admin_changes['project_attrs']['unreadable']
          self.is_paper = model.admin_changes['project_attrs']['is_paper']
          self.implementation_on_main_site = model.admin_changes['project_attrs']['implementation_on_main_site']
          self.contractors_and_costs = model.admin_changes['project_attrs']['contractors_and_costs']

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
        end
      end
    end
  end
end
