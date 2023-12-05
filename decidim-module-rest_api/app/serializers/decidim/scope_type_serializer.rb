# frozen_string_literal: true

module Decidim
  class ScopeTypeSerializer < ActiveModel::Serializer
    type 'scope_type'

    attributes :id,
               :name,

    def name
      object.name["pl"]
    end

  end
end
