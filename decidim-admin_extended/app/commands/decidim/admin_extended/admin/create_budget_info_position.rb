# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a budget info position.
    class Admin::CreateBudgetInfoPosition < Rectify::Command
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

        create_budget_info_position
        broadcast(:ok)
      end

      private

      attr_reader :form, :budget_info_position

      # Private method
      #
      # Creates budget info position
      def create_budget_info_position
        @budget_info_position = BudgetInfoPosition.create(budget_info_position_attributes)
      end

      # Private: attributes of budget info position
      #
      # returns Hash
      def budget_info_position_attributes
        {
          name: @form.name,
          description: @form.description,
          amount: @form.amount,
          file: @form.file,
          published: @form.published,
          weight: @form.weight,
          budget_info_group_id: @form.budget_info_group_id,
          on_main_site: @form.on_main_site
        }
      end
    end
  end
end
