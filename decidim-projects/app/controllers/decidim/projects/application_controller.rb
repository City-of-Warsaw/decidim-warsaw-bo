# frozen_string_literal: true

module Decidim
  module Projects
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController

      private

      # check if action is as searched
      def subaction_for?(subaction)
        params[:subaction] && params[:subaction] == subaction
      end
    end
  end
end
