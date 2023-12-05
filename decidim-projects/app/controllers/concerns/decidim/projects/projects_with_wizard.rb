# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Projects
    module ProjectsWithWizard
      extend ActiveSupport::Concern

      included do
        helper_method :wizard

        private

        def wizard(step = params[:step])
          step = @step
          @wizard ||= Decidim::Projects::ProjectsWizard.new(current_component, step)
        end

        def wizard_init(step)
          @wizard = Decidim::Projects::ProjectsWizard.new(current_component, step)
        end

      end
    end
  end
end
