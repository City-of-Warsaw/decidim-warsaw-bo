# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::ParticipatoryProcesses::Admin::ApplicationController
        def current_participatory_process
          organization_processes.where(slug: params['participatory_process_slug']).or(
            organization_processes.where(id: params['participatory_process_slug'])
          ).first!
        end
        #
        def organization_processes
          @organization_processes ||= Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(Decidim::Organization.first).query
        end
        alias :current_participatory_space :current_participatory_process

      end
    end
  end
end
