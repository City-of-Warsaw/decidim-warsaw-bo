# frozen_string_literal: true

module Decidim
  class ScopeSerializer < ActiveModel::Serializer
    type 'district'

    attributes :id,
               :name,
               :scope_type_id

    def name
      object.name["pl"]
    end

    def scope_type_id
      object.scope_type_id
    end

  end
end
