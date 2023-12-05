# frozen_string_literal: true

require "decidim/projects/admin"
require "decidim/projects/engine"
require "decidim/projects/admin_engine"
require "decidim/projects/component"

module Decidim
  # This namespace holds the logic of the `Projects` component. This component
  # allows users to create projects in a participatory space.
  module Projects
    autoload :ProjectSerializer, "decidim/projects/project_serializer"
    autoload :VoteCardSerializer, "decidim/projects/vote_card_serializer"
    autoload :VoteCardForVerificationSerializer, "decidim/projects/vote_card_for_verification_serializer"
    autoload :ProjectRankSerializer, "decidim/projects/project_rank_serializer"
    autoload :VoteCardAnonymousSerializer, "decidim/projects/vote_card_anonymous_serializer"
  end
end
