# frozen_string_literal: true

module Decidim
  module Projects
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController

        private

        def create_log(project, log_type)
          return unless project

          Decidim.traceability.perform_action!(
            log_type,
            project,
            current_user,
            visibility: "admin-only"
          )
        end

        # check if action is as searched
        def subaction_for?(subaction)
          params[:subaction] && params[:subaction] == subaction
        end
      end
    end
  end
end
