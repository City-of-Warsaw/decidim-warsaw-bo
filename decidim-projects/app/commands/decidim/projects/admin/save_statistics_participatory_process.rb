# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
    # A command with all the business logic when creating or updating statistics for participation process
    class SaveStatisticsParticipatoryProcess < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # participatory_process_id - Id of participatory process.
      # scope_id - Id of selected scope.

      def initialize(form)
        @form = form
        @participatory_process_id =  form.participatory_process_id
        @scope_id = form.scope_id
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the appeal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          save_or_update_statistics_participatory_process
        end
        broadcast(:ok, @statistics)
      end

      private

      attr_reader :form

      # returns Statistics for selectcted participatory process
      def save_or_update_statistics_participatory_process
         if find_statistics_for_process.nil?
           @statistics = Decidim::Projects::StatisticsParticipatoryProcess.new(statistics_attributes).save!
         else
           @statistics = find_statistics_for_process.update(statistics_attributes)
         end
      end

      # Private: statistics_attributes
      #
      # returns Hash
      def statistics_attributes
        {
          # default data
          participatory_process_id: @participatory_process_id,
          scope_id: @scope_id,
          number_of_project_voters_0_18: form.number_of_project_voters_0_18,
          number_of_project_voters_19_24: form.number_of_project_voters_19_24,
          number_of_project_voters_25_34: form.number_of_project_voters_25_34,
          number_of_project_voters_35_44: form.number_of_project_voters_35_44,
          number_of_project_voters_45_64: form.number_of_project_voters_45_64,
          number_of_project_voters_65_100: form.number_of_project_voters_65_100
        }
      end

      def find_statistics_for_process
        Decidim::Projects::StatisticsParticipatoryProcess.find_by(scope_id: @scope_id, participatory_process_id: @participatory_process_id)
      end
    end
    end
  end
end
