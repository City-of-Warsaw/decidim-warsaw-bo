# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe UpdateContactInfoGroup do
        let(:command) { described_class.new(contact_info_group, form) }
        let(:contact_info_group) { create(:contact_info_group) }
        let(:form) { Admin::ContactInfoGroupForm.new }

        it "is not valid" do
          form.name = contact_info_group.name
          form.subtitle = contact_info_group.subtitle
          form.published = contact_info_group.published
          form.weight = nil

          expect { command.call }.to broadcast(:invalid)
        end

        it "is valid" do
          form.name = 'second name'
          form.subtitle = 'second subtitle'
          form.published = false
          form.weight = 1

          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
