require "rails_helper"

describe UsersController do
  describe "GET #show" do
    it "responds successfully with an HTTP 200 status code" do
      user = create(:user)
      get :show, :id => user.sha, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      assert_equal hash_from_json(response.body)["name"], user.name
    end
  end
end


describe UsersController, '.get_current_user' do
  describe "GET #get_current_user" do
    it "responds successfully with an HTTP 200 status code" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      get :get_current_user, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body)["name"], user.name
    end
  end
end
