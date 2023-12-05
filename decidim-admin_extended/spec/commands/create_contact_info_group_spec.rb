# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateContactInfoGroup do
        let(:command) { described_class.new(form) }

        let(:contact_info_group) { create(:contact_info_group) }

        let(:form) { Admin::ContactInfoGroupForm.new }

        it "is not valid" do
          form.name = contact_info_group.name
          form.subtitle = contact_info_group.subtitle
          form.published = nil
          form.weight = contact_info_group.weight

          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::ContactInfoGroup, :count)
        end

        it "is valid" do
          form.name = contact_info_group.name
          form.subtitle = contact_info_group.subtitle
          form.published = contact_info_group.published
          form.weight = contact_info_group.weight

          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::ContactInfoGroup, :count).by(1)
        end
      end
    end
  end
end
