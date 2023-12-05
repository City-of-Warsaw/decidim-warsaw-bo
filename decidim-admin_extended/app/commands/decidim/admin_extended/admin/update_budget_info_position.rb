# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a budget info position.
    class Admin::UpdateBudgetInfoPosition < Rectify::Command
      # Public: Initializes the command.
      #
      # budget_info_position - A budget info position to update.
      # form                 - A form object with the params.
      def initialize(budget_info_position, form)
        @budget_info_position = budget_info_position
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        update_budget_info_position
        broadcast(:ok, budget_info_position)
      end

      private

      attr_reader :form, :budget_info_position

      # Private method
      #
      # Updates budget info position
      def update_budget_info_position
        @budget_info_position.update(budget_info_position_attributes)
      end

      # Private: attributes of budget info position
      #
      # returns Hash
      def budget_info_position_attributes
        {
          name: form.name,
          description: form.description,
          amount: form.amount,
          published: form.published,
          weight: form.weight,
          on_main_site: form.on_main_site,
          budget_info_group_id: form.budget_info_group_id
        }.tap do |hash|
          hash[:file] = form.file if form.file
        end
      end
    end
  end
end
