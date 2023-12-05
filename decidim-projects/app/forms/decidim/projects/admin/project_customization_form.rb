# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # A form object to create and update Project customized form (ProjectCustomization) in admin panel.
      class ProjectCustomizationForm < Form
        BASIC_ATTRIBUTES = %w(title short_description body universal_design universal_design_argumentation
                            justification_info category_ids potential_recipient_ids scope_id
                            localization_info localization_additional_info budget_value)
        BASIC_USER_ATTRIBUTES = %w(first_name last_name gender phone_number email street street_number flat_number zip_code city)

        attribute :process
        attribute :process_slug

        attribute :custom_categories, String
        attribute :custom_recipients, String

        # attachments
        attribute :endorsements, String
        attribute :consents, String
        attribute :files, String
        # user data fields
        attribute :coauthor_email_one, String
        attribute :coauthor_email_one_help_text, String
        attribute :coauthor_email_one_hint, String
        attribute :coauthor_email_two, String
        attribute :coauthor_email_two_help_text, String
        attribute :coauthor_email_two_hint, String

        # agreements fields
        attribute :show_my_name, String
        attribute :inform_me_about_proposal, String
        attribute :email_on_notification, String

        attribute :additional_attributes

        BASIC_ATTRIBUTES.each do |el|
          attribute el, String
          attribute "#{el}_help_text", String
          attribute "#{el}_hint", String
        end

        BASIC_USER_ATTRIBUTES.each do |el|
          attribute el, String
          attribute "#{el}_help_text", String
          attribute "#{el}_hint", String
        end

        def participatory_process
          Decidim::ParticipatoryProcess.find_by(slug: :process_slug)
        end

        def available_types
          [
            ['Pole tekstowe', 'text_field'],
            ['Pole numeryczne', 'number_field']
          ]
        end

        # Public: maps project customization fields into FormObject attributes
        def map_model(model)
          self.process = model.process
          self.process_slug = model.process.slug
          pts = 'activemodel.attributes.project' # project translation scope
          uts = 'decidim.projects.projects.part_form_fields.author_fields' # user translation scope
          self.title = set_custom_name(model,:title, pts)
          self.title_help_text = set_custom_name(model,:title_help_text, pts)
          self.title_hint = set_custom_name(model,:title_hint, pts)
          self.body = set_custom_name(model, :body, pts)
          self.body_help_text = set_custom_name(model, :body_help_text, pts)
          self.body_hint = set_custom_name(model, :body_hint, pts)
          self.scope_id = set_custom_name(model, :scope_id, pts)
          self.scope_id_help_text = set_custom_name(model, :scope_id_help_text, pts)
          self.scope_id_hint = set_custom_name(model, :scope_id_hint, pts)
          self.short_description = set_custom_name(model, :short_description, pts)
          self.short_description_help_text = set_custom_name(model, :short_description_help_text, pts)
          self.short_description_hint = set_custom_name(model, :short_description_hint, pts)
          self.universal_design = set_custom_name(model, :universal_design, pts)
          self.universal_design_help_text = set_custom_name(model, :universal_design_help_text, pts)
          self.universal_design_hint = set_custom_name(model, :universal_design_hint, pts)
          self.universal_design_argumentation = set_custom_name(model, :universal_design_argumentation, pts)
          self.universal_design_argumentation_help_text = set_custom_name(model, :universal_design_argumentation_help_text, pts)
          self.universal_design_argumentation_hint = set_custom_name(model, :universal_design_argumentation, pts)
          self.justification_info = set_custom_name(model, :justification_info, pts)
          self.justification_info_help_text = set_custom_name(model, :justification_info_help_text, pts)
          self.justification_info_hint = set_custom_name(model, :justification_info_hint, pts)
          self.category_ids = set_custom_name(model, :category_ids, pts)
          self.category_ids_help_text = set_custom_name(model, :category_ids_help_text, pts)
          self.category_ids_hint = set_custom_name(model, :category_ids_hint, pts)
          self.potential_recipient_ids = set_custom_name(model, :potential_recipient_ids, pts)
          self.potential_recipient_ids_help_text = set_custom_name(model, :potential_recipient_ids_help_text, pts)
          self.potential_recipient_ids_hint = set_custom_name(model, :potential_recipient_ids_hint, pts)
          self.localization_info = set_custom_name(model, :localization_info, pts)
          self.localization_info_help_text = set_custom_name(model, :localization_info_help_text, pts)
          self.localization_info_hint = set_custom_name(model, :localization_info_hint, pts)
          self.localization_additional_info = set_custom_name(model, :localization_additional_info, pts)
          self.localization_additional_info_help_text = set_custom_name(model, :localization_additional_info_help_text, pts)
          self.localization_additional_info_hint = set_custom_name(model, :localization_additional_info_hint, pts)
          self.budget_value = set_custom_name(model, :budget_value, pts)
          self.budget_value_help_text = set_custom_name(model, :budget_value_help_text, pts)
          self.budget_value_hint = set_custom_name(model, :budget_value_hint, pts)
          # user data
          self.first_name = set_custom_name(model, :first_name, uts)
          self.first_name_help_text = set_custom_name(model, :first_name_help_text, uts)
          self.first_name_hint = set_custom_name(model, :first_name_hint, uts)
          self.last_name = set_custom_name(model, :last_name, uts)
          self.last_name_help_text = set_custom_name(model, :last_name_help_text, uts)
          self.last_name_hint = set_custom_name(model, :last_name_hint, uts)
          self.gender = set_custom_name(model, :gender, uts)
          self.gender_help_text = set_custom_name(model, :gender_help_text, uts)
          self.gender_hint = set_custom_name(model, :gender_hint, uts)
          self.phone_number = set_custom_name(model, :phone_number, uts)
          self.phone_number_help_text = set_custom_name(model, :phone_number_help_text, uts)
          self.phone_number_hint = set_custom_name(model, :phone_number_hint, uts)
          self.email = set_custom_name(model, :email, uts)
          self.email_help_text = set_custom_name(model, :email_help_text, uts)
          self.email_hint = set_custom_name(model, :email_hint, uts)
          self.coauthor_email_one = set_custom_name(model, :coauthor_email_one, pts)
          self.coauthor_email_one_help_text = set_custom_name(model, :coauthor_email_one_help_text, pts)
          self.coauthor_email_one_hint = set_custom_name(model, :coauthor_email_one_hint, pts)
          # address
          self.street = set_custom_name(model, :street, uts)
          self.street_help_text = set_custom_name(model, :street_help_text, uts)
          self.street_hint = set_custom_name(model, :street_hint, uts)
          self.street_number = set_custom_name(model, :street_number, uts)
          self.street_number_help_text = set_custom_name(model, :street_number_help_text, uts)
          self.street_number_hint = set_custom_name(model, :street_number_hint, uts)
          self.flat_number = set_custom_name(model, :flat_number, uts)
          self.flat_number_help_text = set_custom_name(model, :flat_number_help_text, uts)
          self.flat_number_hint = set_custom_name(model, :flat_number_hint, uts)
          self.zip_code = set_custom_name(model, :zip_code, uts)
          self.zip_code_help_text = set_custom_name(model, :zip_code_help_text, uts)
          self.zip_code_hint = set_custom_name(model, :zip_code_hint, uts)
          self.city = set_custom_name(model, :city, uts)
          self.city_help_text = set_custom_name(model, :city_help_text, uts)
          self.city_hint = set_custom_name(model, :city_hint, uts)
          # new elements
          self.additional_attributes = model.additional_attributes || {}
        end

        def set_custom_name(model, attr_name, tr_scope)
          model.custom_names[attr_name.to_sym].presence || model.custom_names[attr_name.to_s].presence || I18n.t(attr_name.to_s, scope: tr_scope, default: '')
        end
      end
    end
  end
end
