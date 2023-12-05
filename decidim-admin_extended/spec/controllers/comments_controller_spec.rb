require 'rails_helper'

RSpec.describe Decidim::AdminExtended::Admin::CommentsController, type: :controller do
  routes { Decidim::AdminExtended::AdminEngine.routes }

  describe "GET #index" do
    it "renders successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
