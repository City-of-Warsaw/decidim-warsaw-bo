# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to update Projects.
    # This form is used on second step of creating projects wizard
    # and allows updating projects draft and moving to another step as it contains validations.
    class ProjectWizardAuthorStepWithValidationsForm < Decidim::Projects::ProjectWizardAuthorStepForm
      mimic :project_wizard_author_step

      validates :first_name, :last_name, presence: true
      validates :gender, inclusion: { in: %w[male female] }
      validates :street, :street_number, :city, presence: true
      validate :validate_zip_code

      private
      def validate_zip_code
        return errors.add(:zip_code, 'nie może być puste') if zip_code.empty?
        return errors.add(:zip_code, 'jest nie poprawne') if zip_code.scan(/\A[0-9]{2}-[0-9]{3}\z/).empty?
      end
    end
  end
end
