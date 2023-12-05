# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessSerializer < ActiveModel::Serializer
    type 'participatory_process'

    attributes :id,
               :name,
               :votingStart,
               :votingEnd

    def name
      object.title["pl"]
    end

    def votingStart
      object.steps.find_by(system_name: 'voting').start_date&.beginning_of_day
    end

    def votingEnd
      # chcemy:
      #   "votingStart": "2015-01-01 00:00:00",
      # mamy:
      #   votingStart": "2023-06-15T00:00:00.000+02:00",
      object.steps.find_by(system_name: 'voting').end_date&.end_of_day
    end

  end
end
