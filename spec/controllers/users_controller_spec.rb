require "rails_helper"

describe UsersController do

  describe "GET #show" do

    it "responds successfully with an HTTP 200 status code" do
      user = authenticate
      get :show, :id => user.sha, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end

  end

  describe "GET #get_current_user" do

    it "responds successfully with an HTTP 200 status code" do
      user = authenticate
      get :get_current_user, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      assert_equal response_json["name"], user.name
    end

    context "when user has papers and assignments" do

      it "should have the correct attributes" do
        user = authenticate
        paper = create(:paper)
        create(:assignment, :reviewer, user:user, paper:paper)

        get :get_current_user, :format => :json

        expect(response).to have_http_status(:success)
        expect(response.status).to eq(200)

        hash = response_json
        assert_equal hash["name"], user.name
      end

    end

  end

  describe "GET #name_lookup" do

    it "requires the user to be authenticated as an editor" do
      get :name_lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:forbidden)

      authenticate(:user)
      get :name_lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:forbidden)

      authenticate(:editor)
      get :name_lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:success)
    end

    it "responds successfully with an HTTP 200 status code and some users" do
      authenticate(:editor)
      user = create(:user, name:'Scooby doo')
      get :name_lookup, :guess => "Scooby", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      # FIXME - this hash structure is kinda silly
      assert_equal response_json.first["sha"], user.sha
    end

    it "responds successfully with an HTTP 200 status code and no users" do
      authenticate(:editor)
      get :name_lookup, :guess => "blah", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      assert response_json.empty?
    end

  end

end
