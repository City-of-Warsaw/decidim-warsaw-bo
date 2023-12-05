# frozen_string_literal: true

module Decidim
  module Projects
    module AdminLog
      # This class holds the logic to present a `Decidim::Projects::Project`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ProjectPresenter.new(action_log, view_helpers).present
      class ProjectPresenter < Decidim::Log::BasePresenter
        private

        # Private: returns presenter of the resource
        def resource_presenter
          @resource_presenter ||= Decidim::Projects::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        # Private: defines all the fields that are supposed to be mapped in diff
        #
        # returns Hash
        def diff_fields_mapping
          {
            title: :string,
            body: :string,
            state: :string,
            verification_status: :string,
            scope: :scope,
            categories: :areas,
            custom_categories: :string,
            recipients: :recipients,
            custom_recipients: :string,
            published_at: :date,
            state: :string,
            short_description: :string,
            universal_design: :boolean,
            universal_design_argumentation: :string,
            justification_info: :string,
            localization_info: :string,
            localization_additional_info: :string,
            locations: :location,
            budget_value: :integer,
            # admin
            no_scope_selected: :boolean,
            contractors_and_costs: :string,
            unreadable: :boolean,
            remarks: :string,
            signed_by_coauthor1: :boolean,
            signed_by_coauthor2: :boolean,
            evaluator: :string,
            evaluation_note: :string,
            verification_status: :string,
            implementation_status: :integer,
            producer_list: :string,
            implementation_on_main_site: :boolean
          }
        end

        # Private: method returns translation for the given action
        def action_string
          case action
          when "create", "update", "accept", "withdrawn", "show", "edit", "change_status"
            # admin actions
            "decidim.projects.admin_log.project.#{action}"
          when "user_create", "user_publish", "user_update", "user_withdraw", "user_draft"
            # city user actions
            "decidim.projects.admin_log.project.#{action}"
          when "forward_to_department", "forward_to_user", "change_verificator", "unassign_verificator"
            # other actions
            "decidim.projects.admin_log.project.#{action}"
          when "create_f_evaluation", "update_f_evaluation", "create_m_evaluation", "update_m_evaluation", "edit_f_evaluation", "edit_m_evaluation"
            # creating and updating evaluations : formal and meritorical both
            "decidim.projects.admin_log.project.#{action}"
          when "send", "return", "return_to_verificator", "changes_for_acceptance", "publish", "formal", "formal_finish", "formal_accepted", "meritorical", "meritorical_finish", "meritorical_accepted", "verification_finish"
            # evaluation flow and paper versions
            "decidim.projects.admin_log.project.#{action}"
          when "create_appeal", "update_appeal", "create_reevaluation", "update_reevaluation", "edit_reevaluation"
            # creating and updating evaluation
            "decidim.projects.admin_log.project.#{action}"
          when "user_publish_appeal", "accept_coauthorship"
            # for creator # coauthor
            "decidim.projects.admin_log.project.#{action}"
          when "finish_appeal_draft", "accept_paper_appeal", "submit_appeal_for_verification", "finish_appeal_verification", "submit_verified_appeal", "reevaluation_finished"
            # reevaluation flow and paper versions
            "decidim.projects.admin_log.project.#{action}"
          when "update_implementation"
            # implementations
            "decidim.projects.admin_log.project.#{action}"
          when "generate_ranking_list","export_voting_card","export_voting_list"
            "decidim.projects.admin_log.project.#{action}"
          when 'export_projects', 'export_projects_with_authors', 'export_authors', 'export_implementations'
            # exports
            "decidim.projects.admin_log.project.#{action}"
          else
            super
          end
        end

        # Private: translation scope
        def i18n_labels_scope
          "activemodel.attributes.project"
        end

        def diff_actions
          super + %w[create update accept withdrawn show edit change_status
                     user_create user_publish user_update user_withdraw user_draft
                     forward_to_department forward_to_user
                     create_f_evaluation update_f_evaluation create_m_evaluation update_m_evaluation edit_f_evaluation edit_m_evaluation
                     send return return_to_verificator changes_for_acceptance publish formal formal_finish formal_accepted meritorical meritorical_finish meritorical_accepted verification_finish
                     create_appeal update_appeal create_reevaluation update_reevaluation edit_reevaluation
                     user_publish_appeal accept_coauthorship
                     finish_appeal_draft accept_paper_appeal submit_appeal_for_verification finish_appeal_verification submit_verified_appeal reevaluation_finished
                     update_implementation
                     export_projects export_projects_with_authors export_authors export_implementations]
        end
      end
    end
  end
end
