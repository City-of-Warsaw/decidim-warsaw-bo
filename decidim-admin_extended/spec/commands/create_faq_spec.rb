# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe CreateFaq do
        let(:command) { described_class.new(form)}
        let(:faq_group) { create(:faq_group)}
        let(:faq) { create(:faq)}
        let(:form) { Admin::FaqForm.new }

        it "is not valid" do
          form.title = nil
          form.content = faq.content
          form.published = faq.published
          form.weight = faq.weight
          form.faq_group_id = faq_group.id

          expect { command.call }.to broadcast(:invalid)
          expect { command.call }.not_to change(Decidim::AdminExtended::Faq, :count)
        end

        it "is valid" do
          form.title = faq.title
          form.content = faq.content
          form.published = faq.published
          form.weight = faq.weight
          form.faq_group_id = faq_group.id

          expect { command.call }.to broadcast(:ok)
          expect { command.call }.to change(Decidim::AdminExtended::Faq, :count).by(1)
        end
      end
    end
  end
end
