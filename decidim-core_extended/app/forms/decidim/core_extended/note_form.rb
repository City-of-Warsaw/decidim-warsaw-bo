# frozen_string_literal: true

module Decidim::CoreExtended
  # A form object to create or update Note.
  class NoteForm < Decidim::Form
    mimic :note

    attribute :title, String
    attribute :body, String

    validates :title, :body, presence: true
  end
end
