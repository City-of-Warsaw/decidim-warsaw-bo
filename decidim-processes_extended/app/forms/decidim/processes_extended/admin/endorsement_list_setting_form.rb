# frozen_string_literal: true

module Decidim
  module ProcessesExtended
    module Admin
      # A form object to create or update document.
      class EndorsementListSettingForm < Form
        mimic :endorsement_list_setting

        attribute :image_header
        attribute :header_description, String
        attribute :footer_description, String
      end
    end
  end
end
