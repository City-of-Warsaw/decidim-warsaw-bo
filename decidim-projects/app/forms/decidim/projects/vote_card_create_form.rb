# frozen_string_literal: true

module Decidim
  module Projects
    # A form object to create Vote with provided email address
    class VoteCardCreateForm < Decidim::Form
      mimic :vote

      attribute :email, String

      validates :email, presence: true
    end
  end
end
