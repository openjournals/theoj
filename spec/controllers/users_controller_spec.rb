require "rails_helper"

describe UsersController do

  describe "GET #show" do

    it "responds successfully with an HTTP 200 status code" do
      user = authenticate
      get :show, :id => user.sha, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      assert_equal hash_from_json(response.body)["name"], user.name
    end

  end

  describe "GET #get_current_user" do

    it "responds successfully with an HTTP 200 status code" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      get :get_current_user, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body)["name"], user.name
    end

    context "when user has papers and assignments" do

      it "should have the correct attributes" do
        user = create(:user)
        paper = create(:paper)
        create(:assignment_as_reviewer, :user => user, :paper => paper)

        # Set paper as for attention of user
        paper.update_attributes(:fao_id => user.id)

        allow(controller).to receive_message_chain(:current_user).and_return(user)
        get :get_current_user, :format => :json

        expect(response).to have_http_status(:success)
        expect(response.status).to eq(200)

        hash = hash_from_json(response.body)
        assert_equal hash["name"], user.name
        assert_equal hash['papers'].length, 0
        assert_equal hash['papers_as_reviewer'].length, 1
        assert_equal hash['papers_as_reviewer'].first['fao_id'], user.id
      end

    end

  end

  describe "GET #name_lookup" do

    it "responds successfully with an HTTP 200 status code and some users" do
      user = create(:user, :name => "Scooby doo")
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      get :name_lookup, :guess => "Scooby", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      # FIXME - this hash structure is kinda silly
      assert_equal hash_from_json(response.body).first["sha"], user.sha
    end

    it "responds successfully with an HTTP 200 status code and no users" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      get :name_lookup, :guess => "blah", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      assert hash_from_json(response.body).empty?
    end

  end

end
