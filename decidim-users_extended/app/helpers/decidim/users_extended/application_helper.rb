# frozen_string_literal: true

module Decidim
  module UsersExtended
    module ApplicationHelper
      include TranslatableAttributes

      def gender_for_select
        Decidim::User::GENDERS.map do |g|
          [
            I18n.t("gender.#{g}", scope: "decidim.comments"),
            g
          ]
        end
      end
    end
  end
end
