# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe CreateRegistration do
    let(:command) { described_class.new(form) }
    let(:password) { 'Decidim123456' }
    let(:organization) { create(:organization) }
    let(:data) do
      {
        name: ::Faker::Lorem.word,
        nickname: ::Faker::Lorem.word,
        email: ::Faker::Internet.email,
        password: password,
        password_confirmation: password,
        tos_agreement: true,
        # custom
        gender: 'male'
      }
    end

    let(:form) do
      Decidim::RegistrationForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        tos_agreement: data[:tos_agreement],
        # custom
        gender: data[:gender],
      ).with_context(current_organization: organization)
    end

    context "when invalid" do
      it "doesn't create user" do
        form.email = nil
        expect { command.call }.to broadcast(:invalid)

        expect do
          command.call
        end.not_to change(Decidim::User, :count)
      end
    end

    context "when valid" do
      it "creates user" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates user with additionsl data" do
        expect do
          command.call
        end.to change(Decidim::User, :count)
        user = Decidim::User.last
        expect(user.gender).to eq(data[:gender])
      end
    end
  end
end
