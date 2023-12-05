# frozen_string_literal: true

module Decidim
  module Projects
    # Simple helpers for public projects view
    module ProjectsHelper

      # show author name on project page
      def author_name(project)
        return I18n.t("decidim.profile.deleted") unless project.creator_author
        return I18n.t("decidim.profile.deleted") if project.creator_author.deleted?

        if project.author_data['show_author_name'] && project.creator_author.name_and_surname.present?
          project.creator_author.name_and_surname
        else
          project.creator_author.anonymous_name
        end
      end

      def budget_value(project)
        project.budget_value.present? ? budget_to_currency(project.budget_value) : '-'
      end

      def show_coauthors?(project)
        project.confirmed_authors_count > 1 || current_user == project.creator_author
      end
    end
  end
end
