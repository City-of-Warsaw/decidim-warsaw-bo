# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a department.
    class Admin::UpdateDepartment < Rectify::Command
      # Public: Initializes the command.
      #
      # department - Department object
      # form - A form object with the params.
      def initialize(department, form)
        @department = department
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

        update_department
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      # updates department
      def update_department
        # Decidim.traceability.update!(
        #   @department,
        #   form.current_user,
        #   attributes
        # )
        @department.update!(attributes)
      end

      # private method
      # maps attributes provided by form
      # that can be updated
      #
      # returns Hash
      def attributes
        {
          active: form.active,
          name: form.name,
          ad_name: form.ad_name,
          allow_returning_projects: form.allow_returning_projects,
          department_ids: form.department_ids,
          department_type: form.department_type
        }
      end
    end
  end
end
