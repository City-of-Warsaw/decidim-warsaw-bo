# frozen_string_literal: true

module Decidim
  ScopeType.class_eval do
    scope :active, -> { where.not(id: nil) }
  end
end
