# frozen_string_literal: true

module Decidim::AdminExtended
  # BanneWords are used by Obscenity to create blacklist of words
  # that can be lately used to check data provided by users to send waring about
  # content that is offensive and against the Organization policy
  class BannedWord < ApplicationRecord
    scope :sorted_by_name, -> { order(:name) }

    validates :name, presence: true
  end
end
