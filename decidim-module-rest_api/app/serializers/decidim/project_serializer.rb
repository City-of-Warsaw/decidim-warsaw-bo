# frozen_string_literal: true

module Decidim
  class ProjectSerializer < ActiveModel::Serializer
    type 'project'

    attributes :id,
               :isPaper,
               :title,
               :status,
               :mainRegionName,
               :regionName,
               :number

    def isPaper
      object.is_paper ? 1 : 0
    end

    # Project status [int] in the system:
    # • -3 - Not selected by vote
    # • -2 - Withdrawn by the author
    # • -1 - Negatively rated
    # • 3 - Submitted
    # • 4 - Evaluation in progress
    # • 5 - Allowed to vote
    # • 6 - Selected by vote - Winning project
    def status
      3
    end

    def mainRegionName
      object.scope&.name['pl']
    end

    def regionName
      object.region&.name
    end

    def number
      object.esog_number
    end
  end
end
