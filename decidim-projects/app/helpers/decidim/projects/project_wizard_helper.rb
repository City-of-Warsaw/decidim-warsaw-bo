# frozen_string_literal: true

module Decidim
  module Projects
    # Simple helpers to handle markup variations for project wizard partials
    module ProjectWizardHelper
      # Returns the css classes used for the project wizard for the desired step
      #
      # step - A symbol of the target step
      # current_step - A symbol of the current user step
      #
      # Returns a string with the css classes for the desired step
      def project_wizard_step_classes(wizard, step)
        if wizard.stepper_active?(step)
          "step--active"
        elsif wizard.stepper_past?(step)
          "step--past"
        end
      end

      def project_files_count(project, attachment_type)
        return unless project

        count = case attachment_type
                when 'add_documents'
                  project.attachments.where(attachment_type: 'document').count
                when 'add_more_documents'
                  project.attachments.where(attachment_type: 'consent').count
                when 'add_photos'
                  project.attachments.where(attachment_type: 'endorsement').count
                when 'add_endorsements'
                  project.endorsements.count
                when 'add_files'
                  project.files.count
                when 'add_consents'
                  project.consents.count
                else
                  project.attachments.where(attachment_type: 'document').count
                end

        return if count == 0

        content_tag :div, class: '' do
          "Liczba załączonych plików: #{count}"
        end.html_safe
      end

      # Returns the page title of the given step, translated
      #
      # action_name - A string of the rendered action
      def project_wizard_step_title(wizard)
        t(wizard.step, scope: 'decidim.projects.projects_wizard.wizard_title')
      end

      # Returns the list item of the given step, in html
      #
      # step - A symbol of the target step
      # current_step - A symbol of the current step
      def project_wizard_stepper_step(wizard, step)
        attributes = { class: project_wizard_step_classes(wizard, step) }
        step_title = t("decidim.projects.projects.wizard_steps.#{step}").html_safe

        if wizard.stepper_active?(step)
          step_title = content_tag(:span, t("decidim.projects.projects.wizard_steps.current_step"), class: 'show-for-sr') + step_title
          attributes['aria-current'] = 'step'
        end

        content_tag(:li, step_title, attributes)
      end

      # Returns the list with all the steps, in html
      #
      # current_step - A symbol of the current step
      def project_wizard_stepper(wizard)
        content_tag :ol, class: 'wizard__steps' do
          Decidim::Projects::ProjectsWizard::STEP_LIST.each do |step_name|
            concat project_wizard_stepper_step(wizard, step_name)
          end
        end
      end

      def project_wizard_steps_title
        t("title", scope: "decidim.projects.projects.wizard_steps")
      end

      # Returns a boolean if the step has a help text defined
      #
      # step - A symbol of the target step
      def project_wizard_step_help_text?(step)
        translated_attribute(component_settings.try("project_wizard_#{step}_help_text")).present?
      end

      # Renders a user_group select field in a form.
      # form - FormBuilder object
      # name - attribute user_group_id
      #
      # Returns nothing.
      def user_group_select_field(form, name)
        selected = @form.user_group_id.presence
        user_groups = Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
        form.select(
          name,
          user_groups.map { |g| [g.name, g.id] },
          selected: selected,
          include_blank: current_user.public_name(true)
        )
      end

      private

      def total_steps
        4
      end

      def wizard_aside_info_text
        t("info", scope: "decidim.projects.projects.wizard_aside").html_safe
      end

      # Renders the back link except for step_2: compare
      def project_wizard_aside_link_to_back(step)
        case step
        when :step_1
          projects_path
        when :step_3
          compare_project_path
        when :step_4
          edit_draft_project_path
        end
      end

      def wizard_aside_back_text(from = nil)
        key = "back"
        key = "back_from_#{from}" if from

        t(key, scope: "decidim.projects.projects.wizard_aside").html_safe
      end
    end
  end
end
