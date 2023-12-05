# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Helper class for Projects in admin panel.
      module ProjectsHelper
        include Decidim::Admin::ResourceScopeHelper
        include Decidim::Projects::SharedHelper

        def coauthor_presenters_for(project)
          project.authors.map do |identity|
            if identity.is_a?(Decidim::Organization)
              Decidim::Proposals::OfficialAuthorPresenter.new
            else
              present(identity)
            end
          end
        end

        def evaluation_actions(project, type)
          eval_links = []
          if allowed_to? :finish_admin_draft, :project_evaluate, project: project
            link = finish_admin_draft_project_evaluations_path(project)
            text = 'Oddaj projekt do rozpatrzenia'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :return_admin_draft, :project_evaluate, project: project
            link = return_admin_draft_project_evaluations_path(project)
            text = 'Cofnij do edytora'
            eval_links << build_evaluation_link(type, link, text, icon = 'arrow-left')

            link = publish_project_project_evaluations_path(project)
            text = 'Opublikuj papierowy projekt'
            eval_links << build_evaluation_link(type, link, text, icon = 'arrow-right', classes = 'button success')
          end

          if allowed_to? :submit_for_formal, :project_evaluate, project: project
            link = choose_verificator_project_evaluations_path(project)
            text = 'Przypisz weryfikatora (ocena formalna)'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :finish_formal, :project_evaluate, project: project
            link = finish_formal_project_evaluations_path(project)
            text = 'Przekaż do koordynatora'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :return_to_verificator, :project_evaluate, project: project
            link = add_note_for_verificator_project_evaluations_path(project)
            text = 'Cofnij projekt do weryfikatora'
            eval_links << build_evaluation_link(type, link, text, icon = 'arrow-left')
          end
          if allowed_to? :accept_formal, :project_evaluate, project: project
            link = accept_formal_project_evaluations_path(project)
            text = 'Zaakceptuj ocenę'
            eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = 'button success', confirmation ='Czy jesteś pewien? Działanie jest nieodwracalne')
          end
          if allowed_to? :submit_for_meritorical, :project_evaluate, project: project
            link = choose_verificator_project_evaluations_path(project)
            text = 'Przypisz weryfikatora (ocena merytoryczna)'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :finish_meritorical, :project_evaluate, project: project
            link = finish_meritorical_project_evaluations_path(project)
            text = 'Przekaż do koordynatora'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :accept_meritorical, :project_evaluate, project: project
            link = accept_meritorical_project_evaluations_path(project)
            text = 'Zaakceptuj ocenę'
            eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = 'button success', confirmation = 'Czy jesteś pewien? Działanie jest nieodwracalne')
          end

          if allowed_to? :finish_project_verification, :project_evaluate, project: project
            link = finish_project_verification_project_evaluations_path(project)
            text = 'Zatwierdź ostateczną ocenę projektu'
            eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = ' button success', confirmation = 'Czy jesteś pewien? Działanie jest nieodwracalne')
          end

          eval_links.join('').html_safe
        end

        def reevaluation_actions(project, type)
          eval_links = []
          if allowed_to? :finish_appeal_draft, :project_reevaluate, project: project
            link = finish_appeal_draft_project_reevaluations_path(project)
            text = 'Przekaż do koordynatora'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :accept_paper_appeal, :project_reevaluate, project: project
            link = accept_paper_appeal_project_reevaluations_path(project)
            text = 'Zaapceptuj odwołanie'
            eval_links << build_evaluation_link(type, link, text, icon = 'check')
          end
          if allowed_to? :submit_for_verification, :project_reevaluate, project: project
            link = choose_verificator_project_reevaluations_path(project)
            text = project.evaluator ? 'Zmień weryfikatora (ponowna ocena)' : 'Przypisz weryfikatora (ponowna ocena)'
            eval_links << build_evaluation_link(type, link, text)
          end
          if allowed_to? :finish_appeal_verification, :project_reevaluate, project: project
            # we show link only on reevaluation view
            # on list we require reevaluation to be created
            if type == 'button' || project.reevaluation
              link = finish_appeal_verification_project_reevaluations_path(project)
              text = 'Przekaż do koordynatora'
              eval_links << build_evaluation_link(type, link, text)
            end
          end
          if allowed_to? :submit_to_organization_admin, :project_reevaluate, project: project
            # we show link only on reevaluation view
            if type == 'button' || project.reevaluation
              link = submit_to_organization_admin_project_reevaluations_path(project)
              text = 'Przekaż do CKS'
              eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = 'button success', confirmation = 'Czy jesteś pewien? Przekazujesz ocenę do CKS.')
            end
          end
          if allowed_to? :accept_coordinator_reevaluation, :project_reevaluate, project: project
            # we show link only on reevaluation view
            if type == 'button' || project.reevaluation
              link = accept_coordinator_reevaluation_project_reevaluations_path(project)
              text = 'Zaakceptuj'
              eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = 'button success', confirmation = 'Czy jesteś pewien? Odwołanie zostanie zaakceptowane')
            end
          end
          if allowed_to? :return_from_admin_to_coordinators, :project_reevaluate, project: project
            # we show link only for admins if appeal can by returned to reverification
            if type == 'button' || project.reevaluation
              link = return_from_admin_to_coordinators_project_reevaluations_path(project)
              text = 'Zwróć do koordynatorów'
              eval_links << build_evaluation_link(type, link, text, icon = 'arrow-left', classes = 'button warning', confirmation = 'Czy jesteś pewien?')
            end
          end
          if allowed_to? :finish_reevaluation, :project_reevaluate, project: project
            # we show link only on reevaluation view
            if type == 'button' || project.reevaluation
              link = finish_reevaluation_project_reevaluations_path(project)
              text = 'Zatwierdź ostateczną ocenę odwołania'
              eval_links << build_evaluation_link(type, link, text, icon = 'check', classes = 'button success', confirmation = 'Czy jesteś pewien? Działanie jest nieodwracalne')
            end
          end

          eval_links.join('').html_safe
        end

        def build_evaluation_link(type, link, text, icon = "arrow-right", classes = 'button', confirmation = nil)
          if type == 'button'
            link_to text, link, class: classes, data: { confirm: confirmation }
          else
            icon_link_to icon, link, text, class: "action-icon--edit", data: { confirm: confirmation }
          end
        end

        def forward_to_department(project, type)
          if allowed_to? :forward_to_department, :project_evaluate, project: project
            link = choose_department_project_evaluations_path(project)
            text = 'Przekaż do komórki'
            build_evaluation_link(type, link, text)
          end
        end

        def return_to_department(project, type)
          if allowed_to? :return_to_department, :project_evaluate, project: project
            link = add_return_reason_project_evaluations_path(project)
            text = 'Zwróć do poprzedniej komórki'
            if type == 'button'
              link_to text, link, class: 'button alert'
            else
              icon_link_to icon, link, text, class: "action-icon--edit alert"
            end
          end
        end

        def check_endorsements_to_delete(project, endorsement)
          return false if project.admin_changes.nil?
          return false if project.admin_changes['files_to_remove'].nil?
          return false if project.admin_changes['files_to_remove'].empty? || project.admin_changes['files_to_remove']['endorsements'].nil?

          project.admin_changes['files_to_remove']['endorsements'].include?(endorsement.id)
        end

        def check_files_to_delete(project, endorsement)
          return false if project.admin_changes.nil?
          return false if project.admin_changes['files_to_remove'].nil?
          return false if project.admin_changes['files_to_remove'].empty? || project.admin_changes['files_to_remove']['files'].nil?

          project.admin_changes['files_to_remove']['files'].include?(endorsement.id)
        end

        def check_consents_to_delete(project, endorsement)
          return false if project.admin_changes.nil?
          return false if project.admin_changes['files_to_remove'].nil?
          return false if project.admin_changes['files_to_remove'].empty? || project.admin_changes['files_to_remove']['consents'].nil?

          project.admin_changes['files_to_remove']['consents'].include?(endorsement.id)
        end

        def check_internal_documents_to_delete(project, endorsement)
          return false if project.admin_changes.nil?
          return false if project.admin_changes['files_to_remove'].nil?
          return false if project.admin_changes['files_to_remove'].empty? || project.admin_changes['files_to_remove']['internal_documents'].nil?

          project.admin_changes['files_to_remove']['internal_documents'].include?(endorsement.id)
        end

        def forward_to_user(project, type)
          if allowed_to? :forward_to_user, :project_evaluate, project: project
            eval_links = []
            if project.current_sub_coordinator
              link = choose_user_project_evaluations_path(project)
              text = 'Zmień podkoordynatora'
              eval_links << build_evaluation_link(type, link, text)

              link = remove_sub_coordinator_project_evaluations_path(project)
              text = 'Usuń przypisanie do podkoordynatora'
              eval_links << build_evaluation_link(type, link, text, icon = '', classes = 'button alert')
            else
              link = choose_user_project_evaluations_path(project)
              text = 'Przekaż do podkoordynatora'
              eval_links << build_evaluation_link(type, link, text)
            end

            eval_links.join('').html_safe
          end
        end

        def change_verificator(project, type)
          if allowed_to? :change_verificator, :project_evaluate, project: project
            eval_links= []
            if project.evaluator
              link = choose_new_verificator_project_evaluations_path(project)
              text = 'Zmień weryfikatora'
              eval_links << build_evaluation_link(type, link, text)

              link = remove_verificator_project_evaluations_path(project)
              text = 'Usuń przypisanie do weryfikatora'
              eval_links << build_evaluation_link(type, link, text, icon = 'arrow-right', classes = 'button alert')
            end
            eval_links.join('').html_safe
          end
        end

        def projects_admin_filter_tree
          {
            t("projects.filters.type", scope: "decidim.projects") => {
              link_to(t("projects", scope: "decidim.projects.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "0"),
                      per_page: per_page) => nil,
              link_to(t("amendments", scope: "decidim.projects.application_helper.filter_type_values"), q: ransak_params_for_query(is_emendation_true: "1"),
                      per_page: per_page) => nil
            },
            t("models.project.fields.state", scope: "decidim.projects") =>
              Decidim::Projects::Project::POSSIBLE_STATES.each_with_object({}) do |state, hash|
                if state == "not_answered"
                  hash[link_to((humanize_project_state state), q: ransak_params_for_query(state_null: 1), per_page: per_page)] = nil
                else
                  hash[link_to((humanize_project_state state), q: ransak_params_for_query(state_eq: state), per_page: per_page)] = nil
                end
              end,
            t("models.project.fields.category", scope: "decidim.projects") => admin_filter_categories_tree(categories.first_class),
            t("projects.filters.scope", scope: "decidim.projects") => admin_filter_scopes_tree(current_component.organization.id)
          }
        end

        def icon_with_link_to_project(project)
          icon, tooltip = if allowed_to?(:create, :proposal_answer, proposal: project) && !project.emendation?
                            [
                              "comment-square",
                              t(:answer_proposal, scope: "decidim.proposals.actions")
                            ]
                          else
                            %w[info, Karta]
                          end
          icon_link_to(icon, project_path(project), tooltip, class: "icon--small action-icon--show-proposal")
        end

        def evaluation_form(evaluation)
          evaluation.is_a?(Decidim::Projects::Admin::FormalEvaluationForm) ? 'form_formal' : 'form_meritorical'
        end

        def admin_public_status(project)
          ps = project.state

          "<strong>#{public_status(project)}</strong><br> (#{I18n.t(ps, scope: 'decidim.admin.filters.projects.state_eq.values')})".html_safe
        end

        def verification_status(project)
          vs = project.verification_status

          case vs
          when nil
            'kopia robocza'
          when 'imported'
            'projekt zaimportowany'
          when 'waiting'
            project.state == 'admin_draft' ? 'czeka na akceptację' : 'czeka na przydzielenie do weryfikatora form.'
          when 'formal'
            'w trakcie oceny formalnej'
          when 'formal_finished'
            'czeka na zatwierdzenie oceny'
          when 'formal_accepted'
            project.formal_result ? 'czeka na przydzielenie do weryfikatora meryt.' : 'czeka na ostateczną akceptację'
          when 'meritorical'
            'w trakcie oceny merytorycznej'
          when 'meritorical_finished'
            'czeka na akceptację oceny'
          when 'meritorical_accepted'
            'czeka na ostateczną akceptację'
          when 'finished'
            state = if project.formal_result && project.meritorical_result
                      "<span class='text-success'>Zaakceptowano</span>"
                    else
                      "<span class='text-alert'>Odrzucono</span>"
                    end
            "oceniony:<br>#{state}".html_safe
            # for re-evaluation:
          when 'appeal_draft'
            'nie zgłoszono - kopia robocza'
          when 'appeal_waiting_acceptance'
            'czeka na akceptację odwołania'
          when 'appeal_waiting'
            'czeka na przydzielenie do weryfikatora'
          when 'appeal_verification'
            'w trakcie weryfikacji'
          when 'appeal_verification_finished'
            'czeka na akceptację koordynatora'
          when 'appeal_coordinator_finished'
            'zaakceptowany przez koordynatora'
          when 'appeal_admin_verification'
            'czeka na akceptację CKS'
          when 'reevaluation_finished'
            state = if project&.final_result
                      "<span class='text-success'>Zaakceptowano</span>"
                    else
                      "<span class='text-alert'>Odrzucono</span>"
                    end
            "oceniony ponownie:<br>#{state}".html_safe
          end
        end

        def reevaluation_status(project)
          rs = project.verification_status

          case rs
          when nil, 'appeal_draft'
            'nie zgłoszono - kopia robocza'
          when 'appeal_waiting_acceptance'
            'czeka na akceptację odwołania'
          when 'appeal_waiting'
            'czeka na przydzielenie do weryfikatora'
          when 'appeal_verification'
            'w trakcie weryfikacji'
          when 'appeal_verification_finished'
            'czeka na akceptację koordynatora'
          when 'appeal_coordinator_finished'
            'zaakceptowany przez koordynatora'
          when 'appeal_admin_verification'
            'czeka na akceptację CKS'
          when 'reevaluation_finished'
            state = if project&.final_result
                      "<span class='text-success'>Zaakceptowano</span>"
                    else
                      "<span class='text-alert'>Odrzucono</span>"
                    end
            "oceniony ponownie:<br>#{state}".html_safe
          else
            'nie zgłoszono - kopia robocza'
          end
        end

        def implementation_status(p)
          is = p.respond_to?(:implementation_status) ? p.implementation_status : p
          I18n.t(is, scope: "decidim.admin.filters.projects.implementation_status_eq.values",
                 default: I18n.t('decidim.admin.filters.projects.implementation_status_eq.values.default'))
        end

        def implementation_stage(p)
          is = p.respond_to?(:implementation_status) ? p.implementation_status : p

          case is
          when 0
            "Odstąpiono od realizacji [#{is}]"
          when 1, 2, 3, 4
            "W trakcie realizacji [#{is}]"
          when 5
            "Pomysł zrealizowany [5]"
          else
            'Nie ustawiono'
          end
        end

        def implementations_for_select
          values = current_user.ad_admin? ? [0, 1, 2, 3, 4, 5] : [1, 2, 3, 4, 5]

          values.map { |v| [implementation_status(v), v] }
        end

        def evaluation_status(e, field)
          if e.details[field] == 1
            'spełniono'
          elsif e.details[field] == 2
            'nie spełniono'
          elsif e.details[field] == 3
            'nie dotyczy'
          end
        end

        def coauthorship_confirmation_status_is_confirmed?(project, user)
          'confirmed' == project.coauthorships.where(author: user).first.confirmation_status
        end

        def in_less_than_3_days(date)
          (date - DateTime.current).to_i <= 3
        end
      end
    end
  end
end
