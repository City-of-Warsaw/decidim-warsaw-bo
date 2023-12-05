# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateFaqGroup do
        let(:command) { described_class.new(form)}

        let(:faq_group) { create(:faq_group)}

        let(:form) { Admin::FaqGroupForm.new }

        it "is not valid" do
          form.title = nil
          form.subtitle = faq_group.subtitle
          form.published = faq_group.published
          form.weight = faq_group.weight
          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::FaqGroup, :count)
        end

        it "is valid" do
          form.title = faq_group.title
          form.subtitle = faq_group.subtitle
          form.published = faq_group.published
          form.weight = faq_group.weight
          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::FaqGroup, :count).by(1)
        end
      end
    end
  end
end
