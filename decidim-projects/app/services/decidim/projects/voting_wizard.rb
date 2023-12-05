# frozen_string_literal: true

module Decidim
  module Projects
    # Class holds all the logic for wizard steps handling
    class VotingWizard
      module STEPS
        # INSTRUCTION = 'instruction'   # old step_1
        # DISTRICT = 'district'         # old step_2
        # GLOBAL_SCOPE = 'global'       # old step_3
        # USER_DATA = 'user_data'      # old step_4
        # SUMMARY = 'summary'           # old step_5
        # CONFIRMATION = 'confirmation' # old step_6
        INSTRUCTION         = 'step_1'
        DISTRICT_INFO       = 'step_2_info'
        DISTRICT_LIST       = 'step_2_list'
        GLOBAL_SCOPE_INFO   = 'step_3_info'
        GLOBAL_SCOPE_LIST   = 'step_3_list'
        USER_DATA           = 'step_4'
        SUMMARY             = 'step_5'
        CONFIRMATION        = 'step_6'
      end
      # STEP_LIST = %w"instruction district global user_data summary confirmation"
      STEPPER_LIST = %w[step_1 step_2 step_3 step_4 step_5 step_6].freeze
      STEP_LIST = %w[step_1 step_2_info step_2_list step_3_info step_3_list step_4 step_5 step_6].freeze

      attr_accessor :step, :projects_component

      def initialize(projects_component, step_name)
        @projects_component = projects_component
        @step = STEP_LIST.include?(step_name) ? step_name : STEPS::INSTRUCTION
      end

      # return number of step from 1 to 6
      def number_for_step(step)
        STEP_LIST.index(step) + 1
      end

      # return step number for stepper
      def number_for_stepper(step)
        STEPPER_LIST.index(step) + 1
      end

      def stepper_number
        number_for_stepper(stepper_step)
      end

      # actual step_number from 1 to 6
      def step_number
        STEP_LIST.index(step) + 1
      end

      def next_step
        if step_number >= STEP_LIST.size
          STEP_LIST.first
        else
          STEP_LIST[step_number]
        end
      end

      # return actual step for stepper
      def stepper_step
        return 'step_2' if %w[step_2_info step_2_list].include?(@step)
        return 'step_3' if %w[step_3_info step_3_list].include?(@step)

        @step
      end

      # return if step from stepper is active
      def stepper_active?(step)
        number_for_stepper(step) == number_for_stepper(stepper_step)
      end

      # return if step from stepper is in past
      def stepper_past?(step)
        number_for_stepper(step) < number_for_stepper(stepper_step)
      end

      def with_form?
        %w[step_2 step_2_list step_3_list step_4].include?(step)
      end

      def partial_name
        "decidim/projects/votes_cards/#{step}"
      end

      def old_step_name
        "step_#{step_number}"
      end

      def step_limit
        if district_step?
          projects_component.process.district_scope_projects_voting_limit
        elsif global_scope_step?
          projects_component.process.global_scope_projects_voting_limit
        else
          0
        end
      end

      # Public method based on step returns Hash of values that are to be set to true in vote statistics.
      # Method does not set keys with false value.
      #
      # Returns Hash
      def retrieve_filters(phrase, categories, recipients)
        attrs = {}
        if district_step?
          attrs[:phrase_filters_for_district_projects] = true if phrase.present?
          attrs[:categories_filters_for_district_projects] = true if categories&.any?
          attrs[:recipients_filters_for_district_projects] = true if recipients&.any?
        elsif global_scope_step?
          attrs[:phrase_filters_for_global_projects] = true if phrase.present?
          attrs[:categories_filters_for_global_projects] = true if categories&.any?
          attrs[:recipients_filters_for_global_projects] = true if recipients&.any?
        end
        attrs
      end

      def district_step?
        step == STEPS::DISTRICT_INFO || step == STEPS::DISTRICT_LIST
      end

      def global_scope_step?
        step == STEPS::GLOBAL_SCOPE_INFO || step == STEPS::GLOBAL_SCOPE_LIST
      end

      def confirmation_step?
        step == STEPS::CONFIRMATION
      end
      alias_method :last_step?, :confirmation_step?

      def edit_form_class
        case step
        when 'step_2_info', 'step_2_list'
          Decidim::Projects::WizardVoteDistrictProjectsForm
        when 'step_3_info', 'step_3_list'
          Decidim::Projects::WizardVoteGlobalProjectsForm
        when 'step_4'
          Decidim::Projects::WizardVoteUserDataForm
        else
          Decidim::Projects::WizardVoteForm
        end
      end

      def update_form_class
        case step
        when 'step_2_list'
          Decidim::Projects::WizardVoteDistrictProjectsForm
        when 'step_3_list'
          Decidim::Projects::WizardVoteGlobalProjectsForm
        when 'step_4'
          Decidim::Projects::WizardVoteUserDataForm
        else
          Decidim::Projects::WizardVoteForm
        end
      end
    end
  end
end
