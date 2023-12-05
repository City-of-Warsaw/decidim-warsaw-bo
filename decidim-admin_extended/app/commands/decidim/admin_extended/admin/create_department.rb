# frozen_string_literal: true

module Decidim
  module AdminExtended
    # A command with all the business logic when creating a department.
    class Admin::CreateDepartment < Rectify::Command
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

        create_department
        broadcast(:ok)
      end

      private

      attr_reader :form

      # private method
      # created department
      def create_department
        d = Department.create!(
          active: form.active,
          name: form.name,
          ad_name: form.ad_name,
          allow_returning_projects: form.allow_returning_projects,
          department_type: form.department_type
        )
        d.departments << Department.where(id: form.department_ids)
        d
      end
    end
  end
end
