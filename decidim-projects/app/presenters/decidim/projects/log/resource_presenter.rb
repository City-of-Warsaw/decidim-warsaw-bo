# frozen_string_literal: true

module Decidim
  module Projects
    module Log
      # ResourcePresenter is used for preparing objects showing difference between
      # versions of Porojects
      class ResourcePresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource (project) name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          if resource.is_a?(Decidim::Projects::VoteCard)
            # for adding link to admin logs
            # Votes are not handled via
            href = "/admin/participatory_processes/#{resource.component.participatory_space.slug}/components/#{resource.component.id}/manage/votes_cards/#{resource.voting_token}"
            name = "Karcie do glosowania - #{resource.card_number}"
            "<a href='#{href}'>#{name}</a>".html_safe
          elsif resource.is_a?(Decidim::Projects::ProjectRank)
            "-"
          else
            Decidim::Projects::ProjectPresenter.new(resource).title
          end
        end
      end
    end
  end
end
