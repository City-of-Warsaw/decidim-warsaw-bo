# frozen_string_literal: true

module Decidim
  module Projects
    #
    # Decorator for SimpleUser
    #
    class SimpleUserPresenter < Decidim::UserPresenter
      # Public: dummy method for nickname
      def nickname
        nil
      end
      # Public: dummy method for has_tooltpi?
      #
      # returns false
      def has_tooltip?
        false
      end

      # Public: default avatar
      def avatar_url
        ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
      end

      # Public: dummy method for profile url
      def profile_url
        return ""
      end

      # Public: dummy method for profile path
      def profile_path
        return ""
      end

      # Public: dummy method for deleted?
      #
      # returns false
      def deleted?
        false
      end

      # Public: dummy method for officialized?
      #
      # returns false
      def officialized?
        false
      end
    end
  end
end
