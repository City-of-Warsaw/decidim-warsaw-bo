# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    module Admin
      # A command with all the business logic when a user starts voting process
      class StartVotingProcess < Rectify::Command

        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # current_user - The current user
        def initialize(process, current_user)
          @process = process
          @current_user = current_user
          # steps
          @step = process.voting_step
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid
        # - :invalid if there was no project
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless process
          return broadcast(:invalid) unless process.ready_to_start_voting?
          return broadcast(:invalid) unless @step

          transaction do
            activate_step
            add_action_log
          end

          broadcast(:ok, @process)
        end

        private

        attr_reader :process, :current_user, :step

        # Private method activating voting step
        def activate_step
          process.steps.where(active: true).each do |step|
            @previous_step = step if step.active?
            step.update!(active: false)
          end
          step.update!(active: true)
        end

        def add_action_log
          Decidim.traceability.perform_action!(
            :start_voting,
            process,
            current_user
          )
        end
      end
    end
  end
end
