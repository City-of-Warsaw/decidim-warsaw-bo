# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe UpdateFaqGroup do
        let(:command) { described_class.new(faq_group, form) }

        let(:faq_group) { create(:faq_group)}

        let(:form) { Admin::FaqGroupForm.new }

        it "is not valid" do
          form.title = faq_group.title
          form.subtitle = faq_group.subtitle
          form.published = faq_group.published
          form.weight = nil
          expect { command.call }.to broadcast(:invalid)
        end

        it "is valid" do
          form.title = 'group_title'
          form.subtitle = 'description'
          form.published = false
          form.weight = 3
          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
