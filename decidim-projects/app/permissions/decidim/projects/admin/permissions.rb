# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # Permissions class defines all the permissions in admin scope
      class Permissions < Decidim::Admin::Permissions
        # Public: main method called to check permissions in the admin scope.
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_project_reading_actions?
          allowed_project_creating_actions?
          allowed_project_updating_actions?
          allowed_project_deleting_actions?
          allowed_project_accepting_actions?
          allowed_project_status_change?
          allowed_project_passing_actions?
          allowed_project_publishing_action?
          allowed_projects_bulk_action?
          allowed_to_send_messages?
          allowed_to_send_message?
          allowed_to_send_implementation_message?
          allowed_to_manage_project_form?
          allowed_to_manage_poster_template?
          allowed_register_project_to_signum?
          allowed_to_accept_coauthor?

          allowed_to_remind_about_drafts?
          allowed_to_remind_about_missing_evaluations?
          allowed_to_notify_authors_about_evaluation_result?
          allowed_to_notify_authors_about_evaluation_results?
          allowed_to_notify_authors_about_all_evaluation_results?

          appeal_action?
          evaluation_action? # pierwsza ocena
          evaluation_edition_action? # Pozwolenie na edycje ocen
          forward_to_department_action? # przekazanie
          return_to_department_action? # zwrócenie
          forward_to_user_action? # przekazanie
          verification_action?
          reevaluation_action? # druga ocena
          second_verification_action?
          change_verificator_action? # smiana lub usuniecie weryfikatora

          implementation_action?
          implementation_index_action?
          projects_export_action?

          allowed_to_mark_conflicts?
          allowed_to_erase_user_data?
          project_conflict_action?

          allowed_to_generate_voting_numbers?
          allowed_to_export_voting_card?
          votes_action?
          voting_list_action?
          ranking_list_action?

          permission_action
        end

        private

        # Public: method for fetching project from the context
        def project
          @project ||= context.fetch(:project, nil)
        end

        # Public: method for fetching appeal from the context
        def appeal
          @appeal ||= context.fetch(:appeal, nil)
        end

        # Public: method for defining scope based on the project
        def scope
          @scope ||= project&.scope.presence || Decidim::Scope.find_by(department_id: project&.current_department_id)
        end

        # Public: method for fetching component from the context
        def component
          @component ||= context.fetch(:component, nil)
        end

        # Public: method for defining edition (participatory process) based on the component
        def edition
          @edition ||= component&.process
        end

        # Public: method for participatory process scope based on the component
        def process
          @process ||= context.fetch(:process, nil)
        end

        # Public: method for fetching vote from the context
        def vote
          @vote ||= context.fetch(:vote, nil)
        end

        # Public: method for determining if appeal managing actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def appeal_action?
          return unless permission_action.subject == :appeal

          if permission_action.action == :edit
            return unless appeal
            return toggle_allow(true) if user.ad_admin?
              # AD_ADMIN CAN ALWAYS EDIT appeal
            if appeal.is_paper?
              return unless appeal.project.withing_reevaluation_time?
              return unless appeal.project.withing_verificators_reevaluation_time?

              toggle_allow(coordinators(user, appeal.project, appeal.project&.scope) ||
                             (appeal.author == user &&
                               appeal.project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_DRAFT,
                                                                       Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION])))
            end
          else
            toggle_allow(user.has_ad_role?)
          end
        end

        # Public: method for determining if evaluation of any kind (forma, meritorical or reevaluation)
        # edit actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        # AD_ADMIN CAN ALWAYS EDIT evaluations
        #
        # Method is used for the views where we need action buttons for all the evaluations
        #
        # returns nothing
        def evaluation_edition_action?
          return unless permission_action.subject == :project_evaluate

          if user.ad_admin? &&
            ((permission_action.action == :edit_formal && project.formal_evaluation) ||
              (permission_action.action == :edit_meritorical && project.meritorical_evaluation) ||
              (permission_action.action == :edit_reevaluation && project.reevaluation))
            # AD_ADMIN CAN ALWAYS EDIT evaluations
            toggle_allow(true)

          elsif permission_action.action == :edit_formal
            # koordynator moze edytowac ocene nawet po akceptacji

            if project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING
              # allowing admin, coordinator and sub_coordinator to create formal evaluation without signing it to themselves
              toggle_allow(project.within_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user))
            elsif project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL
              toggle_allow(project.within_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || project.evaluator == user))
            elsif project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED
              toggle_allow(project.withing_verificators_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || project.evaluator == user))
            else
              # allowing coordinator to edit evaluation after it was accepted
              # in evaluation time
              toggle_allow(project.within_evaluation_time? && coordinators(user, project, scope))
            end

          elsif permission_action.action == :edit_meritorical
            # koordynator moze edytowac ocene nawet po akceptacji,
            return unless project.formal_evaluation
            # return unless project.in_evaluation?
            # jak nie ma jeszcze formalnej oceny lub jeżeli jest negatywna, ale jeszcze nie bylo merytorycznej (np. po edycji oceny formalnej merytoryczna moze juz byc)
            return if project.formal_evaluation.result.nil? || (project.formal_evaluation.negative_result? && project.meritorical_evaluation.nil?)

            if project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED
              # allowing admin, coordinator and sub_coordinator to create meritorical evaluation without signing it to themselves
              toggle_allow(project.within_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user))
            elsif project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL
              toggle_allow(project.within_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || project.evaluator == user))
            elsif project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED
              toggle_allow(project.withing_verificators_evaluation_time? && (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || project.evaluator == user))
            else
              # allowing coordinator to edit evaluation after it was accepted
              # in evaluation time
              toggle_allow(project.within_evaluation_time? && coordinators(user, project, scope))
            end

          elsif permission_action.action == :edit_reevaluation
            # permission for both creating and editing

            # projekt musi miec jakiekolwiek odwolanie oraz nie moze byc zapisany jako draft przez uzytkownika
            return if project.verification_status.blank?
            return if project.verification_status == 'appeal_draft'
            return unless project.withing_reevaluation_time?
            return unless project.appeal

            if user.ad_admin? || coordinators(user, project, scope)
              # koordynator ma miec mozliwosc edycji do konca procesu reewaluacji
              toggle_allow(true)
            elsif project.current_sub_coordinator == user || project.evaluator == user
              # weryfikator ma miec mozliwosc edycji tylko do czasu oznaczonego w etapie
              return unless project.withing_verificators_reevaluation_time?

              if project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING,
                                               Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION])
                toggle_allow(true)
              end
            end
          end
        end

        # Public: method for determining if evaluation action that was called is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # Method handles only formal and meritorical evaluation flow actions.
        #
        # returns nothing
        def evaluation_action?
          return unless project
          return unless permission_action.subject == :project_evaluate
          return if permission_action.action == :forward_to_department
          return if permission_action.action == :forward_to_user

          if permission_action.action == :finish_admin_draft
            return unless project.admin_draft?
            return unless project.verification_status.nil?

            # if submitting paper projects is still possible
            # for current evaluator, scope coordinator, sub_coordinator and ad_admin
            toggle_allow(
              project.within_paper_submit_time? &&
              (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || project.evaluator == user))
          elsif permission_action.action == :return_admin_draft
            return unless project.admin_draft?
            return unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING

            # if submitting paper projects is still possible
            # for ad_admin and scope coordinator and sub_coordinator
            toggle_allow(
              project.within_paper_submit_time? &&
                (user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user))
          elsif permission_action.action == :publish_project
            return unless project.admin_draft?
            return unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::WAITING

            # for ad_admin and scope coordinator
            toggle_allow(user.ad_admin? || coordinators(user, project, scope))

          elsif permission_action.action == :submit_for_formal
            return if project.evaluator
            return unless project.within_evaluation_time?
            return unless project.in_evaluation? # checks only status
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::WAITING,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED])

            # for ad_admin and scope coordinator and sub_coordinator
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)

          elsif permission_action.action == :finish_formal
            return unless project.has_formal_evaluation?
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL

            # for ad_admin and scope coordinator and sub_coordinator till the end of evaluation time
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user ||
                           (project.evaluator == user && project.withing_verificators_evaluation_time?))

          elsif permission_action.action == :accept_formal
            return unless project.has_formal_evaluation?
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::WAITING,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED])

            # for ad_admin and scope coordinator if there formal evaluation and status is waiting (no evaluator) formal (evaluator didnt finish) or formal finish
            toggle_allow(user.ad_admin? || coordinators(user, project, scope))

          elsif permission_action.action == :submit_for_meritorical
            return if project.evaluator
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED])

            return unless project.formal_evaluation
            return if project.formal_evaluation.result.nil? || project.formal_evaluation.negative_result?

            # for ad_admin, scope coordinator and sub_coordinators
            # only if formal result is positive
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)

          elsif permission_action.action == :finish_meritorical
            return unless project.has_meritorical_evaluation?
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL

            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user ||
                           (project.evaluator == user && project.withing_verificators_evaluation_time?))
          elsif permission_action.action == :accept_meritorical
            return unless project.has_meritorical_evaluation?
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED])

            # for ad_admin and scope coordinator if there formal evaluation and status is formal_accepted (no evaluator) meritorical (evaluator didnt finis) or meritorical finish
            toggle_allow(user.ad_admin? || coordinators(user, project, scope))

          elsif permission_action.action == :finish_project_verification
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?

            # for ad_admin and scope coordinator
            # if formal is finished and it is negative
            # or if meritorical is finished
            if (project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED &&
                  project.formal_evaluation && (project.formal_evaluation.result.nil? || project.formal_evaluation.negative_result?)) ||
                project.verification_status == Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_ACCEPTED
              toggle_allow(user.ad_admin? || coordinators(user, project, scope))
            end

          elsif permission_action.action == :submit_for_verification
            return if project.evaluator
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::WAITING,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_ACCEPTED,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED])

            # for showing choosing verificator form
            # for ad_admin, scope coordinator and sub_coordinator
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)

          elsif permission_action.action == :return_to_verificator
            return unless project.evaluator
            return unless project.in_evaluation? # checks only status
            return unless project.within_evaluation_time?
            return unless project.verification_status.in?([Decidim::Projects::Project::VERIFICATION_STATES::FORMAL_FINISHED,
                                                           Decidim::Projects::Project::VERIFICATION_STATES::MERITORICAL_FINISHED])

            # for returning project to verificator
            # for ad_admin, scope coordinator and sub_coordinator
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)
          end
        end

        # Public: method for determining if forwarding project to the department is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def forward_to_department_action?
          return unless project
          return unless project.published?
          return unless permission_action.subject == :project_evaluate
          return unless permission_action.action == :forward_to_department

          toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)
        end

        # Public: method for determining if returning project to the department is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def return_to_department_action?
          return unless permission_action.subject == :project_evaluate
          return unless permission_action.action == :return_to_department
          return unless project
          return unless project.published?
          return unless project.departments.count > 1

          # for admins always
          # for coordinators only if their department says so
          toggle_allow(user.ad_admin? || (coordinators(user, project, scope) && user.department.allow_returning_projects))
        end

        # Public: method for determining if forwarding project to the user is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def forward_to_user_action?
          return unless permission_action.subject == :project_evaluate
          return unless permission_action.action == :forward_to_user
          return unless project
          return unless project.in_evaluation? || project.is_in_reevaluation? # checks only status

          # for choosing a sub_coordinator
          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        # Public: method for determining if changing project's evaluator is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def change_verificator_action?
          return unless permission_action.subject == :project_evaluate
          return unless permission_action.action == :change_verificator
          return unless project
          return unless project.evaluator
          return unless project.in_evaluation? # checks only status
          return if project.any_draft?

          # for changing a verificator
          # for ad_admin, scope coordinator and sub_coordinator
          toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)
        end

        # Public: method for determining if exporting projects to file is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def projects_export_action?
          return unless permission_action.subject == :projects
          return unless permission_action.action == :export

          toggle_allow(true)
        end

        # Public: method for determining if verification actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # Method for showing evaluation-edit-icons on table view
        #
        # returns nothing
        def verification_action?
          return unless project
          return unless project.in_evaluation? # checks only status
          return unless project.within_evaluation_time?
          return unless permission_action.subject == :project_verification
          return unless permission_action.action == :formal ||
                        permission_action.action == :meritorical

          if permission_action.action == :formal && project.verification_status == 'formal'
            toggle_allow(user.ad_admin? || user.ad_coordinator? || project.current_sub_coordinator == user || user == project.evaluator)
          elsif permission_action.action == :meritorical && project.verification_status == 'meritorical'
            toggle_allow(user.ad_admin? || user.ad_coordinator? || project.current_sub_coordinator == user || user == project.evaluator)
          end
        end

        # Public: method for determining if reevaluation action that was called is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # Method handles only reevaluation flow actions.
        #
        # returns nothing
        def reevaluation_action?
          return unless permission_action.subject == :project_reevaluate
          return unless project
          return unless project.withing_reevaluation_time?

          if permission_action.action == :finish_appeal_draft
            return if project.is_in_reevaluation?
            return unless project.appeal
            return unless project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_DRAFT

            # when appeal was added by user and can be submitted
            # we allow admins submit any appeal
            if !project.appeal.is_paper
              toggle_allow(user.ad_admin?)
            else
              toggle_allow(user.ad_admin? ||
                             coordinators(user, project, scope) ||
                             project.current_sub_coordinator == user || project.appeal.author == user)
            end
          elsif permission_action.action == :accept_paper_appeal
            return unless project.appeal
            return unless project.appeal.is_paper
            return unless project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING_ACCEPTANCE

            # we allow admins to to accept any appeal
            if !project.appeal.is_paper
              toggle_allow(user.ad_admin?)
            else
              toggle_allow(user.ad_admin? || coordinators(user, project, scope))
            end
          elsif permission_action.action == :submit_for_verification
            return unless project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED])

            # for paper appeals appeal must first be accepted
            # for choosing verifier while project is not yet in CKS
            # for ad_admin, scope coordinator and subcoordinator
            toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user)
          elsif permission_action.action == :finish_appeal_verification
            # if user is admin or coordinator they skip this action
            return if user.ad_admin? || user.ad_coordinator?
            return unless project.reevaluation
            return unless project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION

            # for submitting department verification
            # for ad_admin, scope coordinator, sub_coordinator and verificator
            toggle_allow(project.current_sub_coordinator == user || project.evaluator == user)
          elsif permission_action.action == :submit_to_organization_admin
            return unless project.reevaluation

            # for approving reevaluation and sending to Admins (CKS)
            # if appeal_waiting (no verificator),
            # appeal_verification (verificator did not send to coordinator) or
            # appeal_verification_finished (verificator did send to coordinator)
            if project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING,
                                                Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION,
                                                Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED,
                                                Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED])

              toggle_allow(coordinators(user, project, scope))
            end
          elsif permission_action.action == :accept_coordinator_reevaluation
            return unless project.reevaluation

            # for approving reevaluation by coordinator
            # if
            # appeal_verification_finished (verificator did send to coordinator)
            if project.verification_status == Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED

              toggle_allow(coordinators(user, project, scope))
            end
          elsif permission_action.action == :return_from_admin_to_coordinators
            return unless project.reevaluation
            return unless project.is_in_reevaluation?
            return unless project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_ADMIN_VERIFICATION,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED])

            # ONLY for ad_admin
            toggle_allow(user.ad_admin?)
          elsif permission_action.action == :finish_reevaluation
            return unless project.reevaluation
            return unless project.is_in_reevaluation?
            return unless project.verification_status.in?([Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_WAITING,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_VERIFICATION_FINISHED,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_ADMIN_VERIFICATION,
                                                           Decidim::Projects::Project::REEVALUATION_STATES::APPEAL_COORDINATOR_FINISHED])

            # ONLY for ad_admin
            toggle_allow(user.ad_admin?)
          end
        end

        # Public: method for determining if reevaluation actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # Method for showing reevaluation-edit-icons on table view
        #
        # returns nothing
        def second_verification_action?
          return unless project
          return unless project.is_in_reevaluation?
          return unless permission_action.subject == :project_verification
          return unless permission_action.action == :appeal_verification

          # when project in reevaluation is in reevaluation
          # for ad_admin, scope coordinator, sub_coordinator and evaluator
          toggle_allow(user.ad_admin? || coordinators(user, project, scope) || project.current_sub_coordinator == user || user == project.evaluator)
        end

        # Public: method for determining if implementation managing actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def implementation_action?
          return unless project
          return unless project.chosen_for_implementation?
          return unless permission_action.subject == :project

          if permission_action.action == :implementation
            toggle_allow(user.ad_admin? || coordinators(user, project, scope))
          elsif permission_action.action == :edit_implementation
            toggle_allow(user.ad_admin?)
          end
        end

        # Public: method for determining if viewing implementations index is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def implementation_index_action?
          return unless permission_action.subject == :implementations
          return unless permission_action.action == :index

          toggle_allow(user.ad_admin? || user.ad_coordinator? || user.ad_sub_coordinator? || user.ad_verifier?)
        end

        # Public: method for determining if viewing project read actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_reading_actions?
          return unless permission_action.subject == :project
          return unless [:show, :index].include? permission_action.action

          if permission_action.action == :show
            toggle_allow(project && user.has_ad_role?)
          else
            toggle_allow(user.has_ad_role?)
          end
        end

        # Public: method for determining if projects creating is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_creating_actions?
          return unless edition&.paper_project_submit_end_date
          return unless permission_action.subject == :project
          return unless permission_action.action == :create

          toggle_allow(user.has_ad_role? && Date.current <= edition.paper_project_submit_end_date)
        end

        # Public: method for determining if projects edition is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_updating_actions?
          return unless project
          return unless permission_action.subject == :project
          return unless permission_action.action == :edit

          # for admins, coordinators, current sub_coordinators and current evaluators (editors and verificators)
          toggle_allow(user.ad_admin? ||
                         (coordinators(user, project, scope) || project.current_sub_coordinator == user) && DateTime.current <= project.reevaluation_publish_date ||
                         (project.evaluator == user) && project.withing_verificators_reevaluation_time? )
        end

        # Public: method for determining if projects deleting is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_deleting_actions?
          return unless project
          return unless permission_action.subject == :project
          return unless permission_action.action == :destroy

          toggle_allow(['draft', 'admin_draft'].include?(project.state) && (user.ad_admin? || coordinators(user, project, scope)))
        end

        # Public: method for determining if projects accepting is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_accepting_actions?
          return unless permission_action.subject == :project
          return unless permission_action.action == :accept

          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        def allowed_to_erase_user_data?

          return unless component
          return unless permission_action.subject == :projects
          return unless permission_action.action == :erase_user_data

          return unless component.process.show_voting_results_button_at <= Time.current

          toggle_allow(user.ad_admin?)
        end
        # Public: method for determining if projects manual status change is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_status_change?
          return unless permission_action.subject == :project
          return unless permission_action.action == :status_change

          toggle_allow(user.ad_admin?)
        end

        # Public: method for determining if projects forwarding is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_passing_actions?
          return unless permission_action.subject == :project
          return unless permission_action.action == :pass

          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        # Public: method for determining if projects publishing is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_project_publishing_action?
          return unless permission_action.subject == :project
          return unless permission_action.action == :publish

          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        # Public: method for determining if projects bulk actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_projects_bulk_action?
          return unless permission_action.subject == :project
          return unless [:bulk_action, :bulk_subcoordinator_action].include?(permission_action.action)

          if permission_action.action == :bulk_action
            toggle_allow(user.ad_admin? || user.ad_coordinator?)
          elsif permission_action.action == :bulk_subcoordinator_action
            toggle_allow(user.ad_admin? || user.ad_coordinator? || user.ad_sub_coordinator?)
          end
        end

        # Public: method for determining if sending bulk messages to projects authors is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_send_messages?
          return unless permission_action.subject == :project
          return unless permission_action.action == :bulk_message_send

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

        # Public: method for determining if sending message to authors of given project is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_send_message?
          return unless project
          return unless permission_action.subject == :project
          return unless permission_action.action == :send_message

          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        # Public: method for determining if sending message to authors of given project
        # about update in implementation is allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_send_implementation_message?
          return unless project
          return unless permission_action.subject == :project
          return unless permission_action.action == :send_implementation_message

          toggle_allow(user.ad_admin? || coordinators(user, project, scope))
        end

        # Tylko admin i koordynator moga rejestrowac dokumenty w signum
        def allowed_register_project_to_signum?
          return unless permission_action.subject == :project && permission_action.action == :register_to_signum
          return if project.signum_znak_sprawy.present?

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

        def allowed_to_accept_coauthor?
          return unless permission_action.subject == :project && permission_action.action == :coauthor_accept

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

        # Public: allow remind users about drafts projects
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_remind_about_drafts?
          return unless component
          return unless permission_action.subject == :projects
          return unless permission_action.action == :remind_about_drafts

          toggle_allow(user.ad_admin? && component.participatory_space.submitting_step&.active_step?)
        end

        # Public: allow remind coordinators about missing evaluations
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_remind_about_missing_evaluations?
          return unless component
          return unless permission_action.subject == :projects
          return unless permission_action.action == :remind_about_missing_evaluations

          toggle_allow(user.ad_admin? && component.participatory_space.evaluation_step&.active_step?)
        end

        # Public: allow notification about about_evaluation results (positive or negative) for specific project
        # Only coordinators and admin can send notifications
        # Action i possible only on evaluation_publish_date day, after specific hour
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_notify_authors_about_evaluation_result?
          return unless permission_action.subject == :projects
          return unless permission_action.action == :notify_authors_about_evaluation_result
          return if project.component.participatory_space.evaluation_publish_date.to_date != Date.current
          return if project.component.participatory_space.evaluation_publish_date >= DateTime.current
          return unless project.component.participatory_space.evaluation_step&.active_step?

          toggle_allow(user.ad_admin? || (user.ad_coordinator? && (project.current_department_id == user.department.id)))
        end

        # Public: allow notification about about_evaluation results (positive or negative)
        # Only coordinators and admin can send notifications
        # Action i possible only on evaluation_publish_date day, after specific hour
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def allowed_to_notify_authors_about_evaluation_results?
          return unless component
          return unless permission_action.subject == :projects
          return unless permission_action.action == :notify_authors_about_evaluation_results
          return if component.participatory_space.evaluation_publish_date.to_date != Date.current
          return if component.participatory_space.evaluation_publish_date >= DateTime.current
          return unless component.participatory_space.evaluation_step&.active_step?

          toggle_allow(user.ad_admin? || user.ad_coordinator?)
        end

        # Only admin can notify all authors
        # only date
        def allowed_to_notify_authors_about_all_evaluation_results?
          return unless component
          return unless permission_action.subject == :projects
          return unless permission_action.action == :notify_authors_about_all_evaluation_results
          return if component.participatory_space.evaluation_publish_date.to_date != Date.current
          return if component.participatory_space.evaluation_publish_date >= DateTime.current
          return unless component.participatory_space.evaluation_step&.active_step?

          toggle_allow(user.ad_admin?)
        end

        # Public: allow generate voting_numbers fol voting list,
        # action is fo ad_admin only, only before start voting process
        #
        # returns nothing
        def allowed_to_generate_voting_numbers?
          return unless permission_action.subject == :projects
          return unless permission_action.action == :generate_voting_numbers
          return unless component
          return unless component.process.ready_to_start_voting?

          toggle_allow(user.ad_admin?)
        end


        # Public: allow export voting list,
        # action is for ad_admin only
        #
        # returns nothing
        def allowed_to_export_voting_card?
          return unless permission_action.subject == :projects
          return unless permission_action.action == :export_voting_card
          return unless component.process.voting_step.end_date > Time.current

          toggle_allow(user.ad_admin?)
        end


        # Public: method for determining if votes managing actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def votes_action?
          return unless permission_action.subject == :votes

          if permission_action.action == :status_change
            return unless vote.voting_token.present?
            toggle_allow(user.ad_admin?)
          elsif permission_action.action == :edit_email
            return unless vote
            toggle_allow(user.ad_admin?) && vote.status == Decidim::Projects::VoteCard::STATUSES::LINK_SENT
          elsif permission_action.action == :create
            return if component.process.paper_voting_submit_end_date <= Time.current

            toggle_allow(user.ad_admin? || user.ad_coordinator? || user.ad_editor?)
          elsif permission_action.action.in?([:read, :edit])
            return unless vote
            return if vote.voting_token.blank? && permission_action.action == :edit

            if vote.status == Decidim::Projects::VoteCard::STATUSES::WAITING
              # for admins, coordinators from given scope & editors that created vote
              toggle_allow(user.ad_admin? ||
                             (user.ad_coordinator? && user.assigned_scope_id.present? && user.assigned_scope_id == vote.scope_id) ||
                             (user.ad_editor? && vote.author_id == user.id))
            else
              toggle_allow(user.ad_admin?)
            end
          elsif permission_action.action == :publish
            return unless vote
            return unless vote.status == Decidim::Projects::VoteCard::STATUSES::WAITING
            return unless vote.voting_token.present?

            toggle_allow(user.ad_admin? || (user.ad_coordinator? && user.assigned_scope_id.present? && user.assigned_scope_id == vote.scope_id))
          elsif permission_action.action == :index
            # only for admins and coordinators from departments assigned to scopes
            toggle_allow(user.ad_admin? || (user.ad_coordinator? && user.assigned_scope_id.present?) || user.ad_editor?)
          elsif permission_action.action == :export
            # only for admins and coordinators from departments assigned to scopes
            toggle_allow(user.ad_admin? || (user.ad_coordinator? && user.assigned_scope_id.present?))
          elsif permission_action.action == :export_for_verification
            toggle_allow(user.ad_admin?)
          elsif permission_action.action == :verify
            toggle_allow(user.ad_admin?)

          elsif permission_action.action == :resend_email_vote
            return unless vote
            return unless vote.status == Decidim::Projects::VoteCard::STATUSES::LINK_SENT
            return unless vote.is_paper == false
            return unless vote.voting_token.present?

            toggle_allow(user.ad_admin?)
          elsif permission_action.action == :resend_all_email_votes
            toggle_allow(user.ad_admin?)

          elsif permission_action.action == :get_link_for_vote
            return unless vote
            return unless vote.status == Decidim::Projects::VoteCard::STATUSES::LINK_SENT
            return unless vote.is_paper == false

            toggle_allow(user.ad_admin?)
          end
        end

        # Public: method for determining if voting lists actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def voting_list_action?
          return unless permission_action.subject == :voting_list

          toggle_allow(user.ad_admin?)
        end

        # Public: method for determining if ranking lists actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def ranking_list_action?
          return unless permission_action.subject == :ranking_list

          toggle_allow(user.ad_admin?)
        end

        def allowed_to_mark_conflicts?
          return unless permission_action.action == :mark_conflicts

          toggle_allow(user.ad_admin?)
        end

        # Public: method for determining if project conflict handling actions are allowed.
        # Based on the outcome, method sets the permission_action as allowed or disallowed.
        #
        # returns nothing
        def project_conflict_action?
          return unless permission_action.subject == :project_conflict

          toggle_allow(user.ad_admin?)
        end
      end
    end
  end
end
