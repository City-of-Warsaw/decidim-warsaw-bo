# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when updating a budget info group.
    class Admin::UpdateBudgetInfoGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # budget_info_group - A budget info group to update.
      # form              - A form object with the params.
      def initialize(budget_info_group, form)
        @budget_info_group = budget_info_group
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

        update_budget_info_group
        broadcast(:ok, budget_info_group)
      end

      private

      attr_reader :form, :budget_info_group

      # Private method
      #
      # Updates budget info group
      def update_budget_info_group
        @budget_info_group.update(budget_info_group_attributes)
      end

      # Private: attributes of budget info group
      #
      # returns Hash
      def budget_info_group_attributes
        {
          name: form.name,
          subtitle: form.subtitle,
          published: form.published,
          weight: form.weight
        }
      end
    end
  end
end
