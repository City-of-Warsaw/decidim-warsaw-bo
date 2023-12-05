# frozen_string_literal: true

require "rails_helper"
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    module Admin
      describe UpdateFaq do
        let(:command) { described_class.new(faq, form)}
        let(:faq_group) { create(:faq_group)}
        let(:faq_group_second) { create(:faq_group)}
        let(:faq) { create(:faq)}
        let(:form) { Admin::FaqForm.new }

        it "is not valid" do
          form.title = faq.title
          form.content = nil
          form.published = faq.published
          form.weight = faq.weight
          form.faq_group_id = faq.faq_group.id
          expect { command.call }.to broadcast(:invalid)
        end

        it "is valid" do
          form.title = 'other title'
          form.content = 'other content'
          form.published = false
          form.weight = 2
          form.faq_group_id = faq_group_second.id
          expect { command.call }.to broadcast(:ok)
        end
      end
    end
  end
end
