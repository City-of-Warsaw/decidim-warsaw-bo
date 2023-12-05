# frozen_string_literal: true

module Decidim
  module CoreExtended
    # Custom helpers, scoped to the core_extended engine.
    #
    module ApplicationHelper

      def user_menu_class(menu_element)
        "menu-link #{'active ' if controller_name == menu_element}"
      end

    end
  end
end
