require "rails_helper"

describe PapersController do
  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index, :format => :json
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end
end
