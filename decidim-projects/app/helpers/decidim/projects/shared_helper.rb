# frozen_string_literal: true

module Decidim
  module Projects
    # Custom helpers, scoped to the projects engine.
    module SharedHelper
      def project_locator(project)
        Decidim::Projects::ProjectLocatorPresenter.new(project)
      end

      def project_title_for_admin(project)
        project.esog_number ? "#{project.esog_number} - #{project.title}" : project.title
      end

      def path_for_project(project)
        "/processes/#{project.participatory_space.slug}/f/#{project.decidim_component_id}/projects/#{project.id}"
      end

      def public_status(project)
        ps = project.state

        scope = 'decidim.admin.filters.projects.state_eq.values'
        case ps
        when nil
          I18n.t('draft', scope: scope)
        when 'admin_draft', 'draft', 'selected', 'not_selected'
          I18n.t(ps, scope: scope)
        when 'published'
          id = project.component.step_settings.map { |s| s[0] if s[1].creation_enabled }
          step = Decidim::ParticipatoryProcessStep.find_by(id: id[0].to_i)
          step && step.end_date < DateTime.current ? I18n.t('evaluation', scope: scope) : I18n.t('submited', scope: scope)
        when 'accepted', 'rejected'
          if project.reevaluation_publish_date < DateTime.current
            I18n.t(ps, scope: scope)
          elsif project.evaluation_publish_date < DateTime.current && DateTime.current <= project.reevaluation_publish_date
            if project.reevaluation.present?
              # before reevaluation, reveal time every project with reevaluation has public state set as rejected
              I18n.t('rejected', scope: scope)
            else
              # without reevaluation we set public state based on formal and meritorical result values
              if I18n.t('accepted', scope: scope)
                project.formal_result && project.meritorical_result ? I18n.t('accepted', scope: scope) : I18n.t('rejected', scope: scope)
              else
                I18n.t('rejected', scope: scope)
              end
            end
          else
            I18n.t('evaluation', scope: scope)
          end
        when 'withdrawn'
          I18n.t('withdrawn', scope: scope)
        else
          ps
        end
      rescue
        'Brak dat w edycjach'
      end

      def status_class_for_public_status(project)
        ps = public_status(project)

        case ps
        when 'Trwa ocena'
          id = project.component.step_settings.map { |s| s[0] if s[1].creation_enabled }
          step = Decidim::ParticipatoryProcessStep.find_by(id: id[0].to_i)
          step && step.end_date < DateTime.current ? 'orange-filled' : 'blue-outlined'
        when 'Dopuszczony do głosowania'
          'green-outlined'
        when 'Oceniony negatywnie', 'Niewybrany w głosowaniu'
          'red-filled'
        when 'Wybrany w głosowaniu'
          'green-filled'
        else
          ''
        end
      end

      def public_reevaluation_status(project)
        case project.verification_status
        when nil, 'appeal_draft'
          'nie zgłoszono - kopia robocza'
        when 'appeal_waiting', 'appeal_verification', 'appeal_verification_finished', 'appeal_admin_verification'
          'w trakcie weryfikacji'
        when 'reevaluation_finished'
          state = project&.final_result ? "Zaakceptowano" : "Odrzucono"
          "oceniony ponownie:<br>#{state}".html_safe
        else
          'nie zgłoszono - kopia robocza'
        end
      end

      def status_class_for_reevaluation_status(project)
        case project.verification_status
        when nil, 'appeal_draft'
          ''
        when 'appeal_waiting', 'appeal_verification', 'appeal_verification_finished', 'appeal_admin_verification'
          'orange-filled'
        when 'reevaluation_finished'
          state = project&.final_result ? 'green-outlined' : 'red-filled'
          "oceniony ponownie:<br>#{state}".html_safe
        else
          ''
        end
      end

      def implementation_status(project)
        is = project.implementation_status

        case is
        when 0
          # abandoned - odstapiono
          s = 'abandoned'
        when 1, 2, 3, 4
          # in_progress - w trakcie realizacji
          s = 'in_progress'
        when 5
          # finished - zrealizowano
          s = 'finished'
        else
          s = 'in_progress'
        end
        I18n.t(s, scope: "decidim.admin.filters.projects.implementation_state_eq.values")
      end

      # Public method that returns proper text for attribute form element:
      # - custom_form - Decidim::Project::ProjectCustomization
      # - attr - String or Symbol - attribute of Decidim::Projects::Project that can be given custom texts
      # - type - String - type of text that we need:
      #   - 'label' - Attribute label
      #   - 'label_no_asterix' - (for comapre view)
      #   - 'hint' - displayed in tooltip
      #   - 'help_text' - displayed below label
      # - tr_scope - String - scope for attribute translation if there was no custom text available
      #
      # Returns: String or nil
      def customized_attribute_texts(custom_form, attr, type, tr_scope = 'activemodel.attributes.project')
        text = if type == 'label'
                 custom_form&.get_custom_label(attr).presence || t("#{attr}_label", scope: tr_scope, default: '').presence || t(attr, scope: tr_scope)
               elsif type == 'label_no_asterix'
                 initial_label = custom_form&.get_custom_label(attr).presence || t("#{attr}_label", scope: tr_scope, default: '').presence || t(attr, scope: tr_scope)
                 # for this it is removed from the end of the String, to display label on confirmation view without asterix
                 # for example: "Email *" will need to be changed to "Email"
                 # initial_label[-2..-1] == ' *' ? initial_label[0..-3] : initial_label
                 !!(/.+\s\*$/.match initial_label) ? initial_label.match(/.+[^\s\*$]/)[0] : initial_label
               else
                 custom_form && custom_form.custom_names[attr].presence || t(attr, scope: tr_scope, default: '').presence || nil
               end
        # for hints that are displayed in tooltip we remove tags
        type == 'hint' ? decidim_sanitize(text, strip_tags: true) : text&.html_safe
      end

      def custom_tooltip_helper_icon(tooltip_text)
        return '' if tooltip_text.blank?

        (content_tag :span,
                     title: tooltip_text,
                     data: { tooltip: true, disable_hover: false, keep_on_hover: true },
                     class: "additional-hint",
                     "aria-haspopup": true do
          (content_tag(:span, '', "aria-hidden": true)) + (content_tag(:span, tooltip_text, class: "show-for-sr"))
        end
        ).html_safe
      end
    end
  end
end
