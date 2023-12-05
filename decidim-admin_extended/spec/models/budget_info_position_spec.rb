# frozen_string_literal: true

require 'rails_helper'
require "decidim/admin_extended/test/factories"

module Decidim
  module AdminExtended
    describe BudgetInfoPosition, type: :model do
      let(:budget_info_group) { create(:budget_info_group) }
      let(:budget_info_position) { create(:budget_info_position, budget_info_group: budget_info_group) }
      let(:file_path) { Rails.root.join('decidim-admin_extended', 'spec', 'fixtures', 'files', 'spec_file_valid_1.pdf') }
      let(:file) { fixture_file_upload(file_path, 'application/pdf') }

      before do
        budget_info_position.file.attach(file)
      end

      context "budget info position scopes" do
        it "filter only published records" do
          expect(Decidim::AdminExtended::BudgetInfoPosition.published).to eq(Decidim::AdminExtended::BudgetInfoPosition.where(published: true))
        end

        it "checks query for published_on_main_page" do
          expect(Decidim::AdminExtended::BudgetInfoPosition.published_on_main_page).to eq(Decidim::AdminExtended::BudgetInfoPosition.published.where(on_main_site: true))
        end

        it "checks the sorting of records by their weight" do
          expect(Decidim::AdminExtended::BudgetInfoPosition.sorted_by_weight).to eq(Decidim::AdminExtended::BudgetInfoPosition.order(:weight))
        end
      end

      context "tests accociations" do
        it { expect(budget_info_position.file).to be_an_instance_of(ActiveStorage::Attached::One) }
        it { expect(budget_info_position.file).to be_attached }

        it "tests belongs to parent" do
          association = Decidim::AdminExtended::BudgetInfoPosition.reflect_on_association(:budget_info_group)

          expect(association.macro).to eq(:belongs_to)
        end
      end

      it "is valid if the file is within the size limit and have right extensions" do
        expect(budget_info_position).to be_valid
      end

      context "tests validation for the file that exceeds the size limit" do
        let(:file_path) { Rails.root.join('decidim-admin_extended', 'spec', 'fixtures', 'files', 'spec_file_invalid_size.pdf') }
        let(:file) { fixture_file_upload(file_path, 'application/pdf') }

        xit { expect(budget_info_position).not_to be_valid }
        xit { expect(budget_info_position.errors[:file]).to include("Maksymalny rozmiar pliku to 50MB") }
      end

      context "tests validation for the file that have invalid extension" do
        let(:file_path) { Rails.root.join('decidim-admin_extended', 'spec', 'fixtures', 'files', 'spec_file_invalid_ext.svg') }
        let(:file) { fixture_file_upload(file_path, 'image/svg') }

        it { expect(budget_info_position).not_to be_valid }
        xit { expect(budget_info_position.errors[:file]).to include("Dozwolne rozszerzenia plików: jpg jpeg gif png bmp pdf doc") }
      end

      context "when file is not attached" do
        it "is valid" do
          expect(budget_info_position).to be_valid
        end
      end
    end
  end
end
