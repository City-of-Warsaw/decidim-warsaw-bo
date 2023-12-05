# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a budget info group.
    class Admin::CreateBudgetInfoGroup < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
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

        create_budget_info_group
        broadcast(:ok)
      end

      private

      attr_reader :form, :budget_info_group

      # Private method
      #
      # Creates budget info group
      def create_budget_info_group
        @budget_info_group = BudgetInfoGroup.create(budget_info_group_attributes)
      end

      # Private: attributes for budget info group
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
