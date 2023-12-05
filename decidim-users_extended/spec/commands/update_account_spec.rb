# frozen_string_literal: true

require "rails_helper"

module Decidim
  describe UpdateAccount do
    let(:command) { described_class.new(user, form) }
    let(:user) { create(:user, :confirmed) }
    let(:data) do
      {
        name: user.name,
        nickname: user.nickname,
        email: user.email,
        password: nil,
        password_confirmation: nil,
        avatar: nil,
        remove_avatar: nil,
        personal_url: "https://example.org",
        about: "This is a description of me",
        # custom
        gender: 'male'
      }
    end

    let(:form) do
      Decidim::AccountForm.from_params(
        name: data[:name],
        nickname: data[:nickname],
        email: data[:email],
        password: data[:password],
        password_confirmation: data[:password_confirmation],
        avatar: data[:avatar],
        remove_avatar: data[:remove_avatar],
        personal_url: data[:personal_url],
        about: data[:about],
        # custom
        gender: data[:gender],
      ).with_context(current_organization: user.organization, current_user: user)
    end

    # context "when invalid" do
    #   it "doesn't update birth year" do
    #     form.birth_year = Date.current.year
    #     old_birth_year = user.birth_year
    #     expect { command.call }.to broadcast(:invalid)
    #     expect(user.reload.birth_year).to eq(old_birth_year)
    #   end
    # end

    context "when valid" do
      # it "updates the users's birth year" do
      #   form.birth_year = 1980
      #   expect { command.call }.to broadcast(:ok)
      #   expect(user.reload.birth_year).to eq(1980)
      # end

      it "updates the users's gender" do
        form.gender = "female"
        expect { command.call }.to broadcast(:ok)
        expect(user.reload.gender).to eq("female")
      end

      # it "updates the users's district" do
      #   form.district = "Ochota"
      #   expect { command.call }.to broadcast(:ok)
      #   expect(user.reload.district).to eq("Ochota")
      # end
    end
  end
end
