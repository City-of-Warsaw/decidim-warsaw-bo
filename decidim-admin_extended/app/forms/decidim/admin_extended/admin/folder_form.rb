# frozen_string_literal: true

module Decidim
  module AdminExtended
    module Admin
      # A form object to create a folder
      class FolderForm < Form

        attribute :name, String

        mimic :folder

        validates :name, presence: true
      end
    end
  end
end
