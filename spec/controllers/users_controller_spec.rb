require "rails_helper"

describe UsersController do
  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      user = create(:user)
      get :show, :id => user.sha, :format => :json
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json") 
    end
  end
end
