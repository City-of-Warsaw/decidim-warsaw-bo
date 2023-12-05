# frozen_string_literal: true

module Decidim
  class ProjectMapSerializer < ActiveModel::Serializer
    type 'project'

    attributes :id,
               :title,
               :lat,
               :lng,
               :progress

    def lat
      return unless first_location

      first_location[1]['lat']
    end

    def lng
      return unless first_location

      first_location[1]['lng']
    end

    # Etap realizacji. [int]
    #
    # Tłumaczenia wartości w systemie:
    # 1.	Wartości w zakresie 1-4 – „W trakcie realizacji”
    # 2.	Wartość równa 5 – „Zrealizowano”
    def progress
      object.implementation_status
    end

    def first_location
      object.locations.first
    end
  end
end
