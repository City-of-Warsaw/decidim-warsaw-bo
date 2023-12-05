# frozen_string_literal: true

module Decidim
  module Projects
    # Class holds all the logic for wizard steps handling
    class ProjectsWizard
      module STEPS
        DRAFT         = 'step_1_draft'
        AUTHOR        = 'step_2_author'
        PREVIEW       = 'step_3_preview'
        CONFIRMATION  = 'step_4_confirmation'
      end
      STEP_LIST = %w[step_1_draft step_2_author step_3_preview step_4_confirmation].freeze

      attr_accessor :step, :projects_component

      def initialize(projects_component, step_name)
        @projects_component = projects_component
        @step = step_name.to_s
      end

      # return step number for stepper
      def number_for_stepper(step)
        STEP_LIST.index(step.to_s) + 1
      end

      # actual step_number from 1 to 4
      def step_number
        STEP_LIST.index(step) + 1
      end

      def stepper_step
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

      def confirmation_step?
        # confirmation
        step == STEPS::CONFIRMATION
      end

      alias_method :last_step?, :confirmation_step?

    end
  end
end
