# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateContactInfoPosition do
        let(:command) { described_class.new(form) }
        let(:contact_info_group) { create(:contact_info_group) }
        let(:contact_info_position) { create(:contact_info_position) }
        let(:form) { Admin::ContactInfoPositionForm.new }

        it "is not valid" do
          form.name = contact_info_position.name
          form.position = contact_info_position.position
          form.phone = contact_info_position.phone
          form.email = "mail"
          form.published = contact_info_position.published
          form.weight = contact_info_position.weight
          form.contact_info_group_id = contact_info_position.contact_info_group_id

          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::ContactInfoPosition, :count)
        end

        it "is valid" do
          form.name = contact_info_position.name
          form.position = contact_info_position.position
          form.phone = contact_info_position.phone
          form.email = contact_info_position.email
          form.published = contact_info_position.published
          form.weight = contact_info_position.weight
          form.contact_info_group_id = contact_info_group

          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::ContactInfoPosition, :count).by(1)
        end
      end
    end
  end
end
