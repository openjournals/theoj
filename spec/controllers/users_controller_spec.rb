require "rails_helper"

describe UsersController do

  describe "GET #show" do

    context "when no user is authenticated" do

      it "responds successfully with an HTTP 200 status code" do
        get :show, :format => :json

        expect(response).to have_http_status(:success)
        expect(response.status).to eq(200)
      end

      it "should return an empty object" do
        get :show, :format => :json

        expect( response_json ).to be_empty
      end

    end

    context "when no user is authenticated" do

      it "responds successfully with an HTTP 200 status code" do
        user = authenticate
        get :show, :format => :json

        expect(response).to have_http_status(:success)
        expect(response.status).to eq(200)
      end

      it "should return the users details" do
        user = authenticate
        get :show, :format => :json

        expect( response_json["name"] ).to eq(user.name)
        expect( response_json["email"]).to eq(user.email)
      end

      context "when user has papers and assignments" do

        it "should have the correct attributes" do
          user = authenticate
          paper = create(:paper)
          create(:assignment, :reviewer, user:user, paper:paper)

          get :show, :format => :json

          expect(response).to have_http_status(:success)
          expect(response.status).to eq(200)

          hash = response_json
          assert_equal hash["name"], user.name
        end

      end

    end

  end

  describe "PUT #update" do

    it "should fail if the user is not authenticated" do
      put :update
      expect(response).to have_http_status(:unauthorized)
    end

    it "should succeed" do
      user = authenticate
      put :update, format: :json, user:{ email:'1@2.com' }
      expect(response).to have_http_status(:ok)
    end

    it "should change the user's attributes" do
      user = authenticate
      put :update, format: :json, user:{ email:'1@2.com' }
      expect(user.reload.email).to eq('1@2.com')
    end

    it "should render a user" do
      user = authenticate
      put :update, format: :json, user:{ email:'1@2.com'}
      expect(response_json['name']).to eq(user.name)
      expect(response_json['email']).to eq('1@2.com')
    end

    it "should not change unexpected parameters" do
      user = authenticate
      put :update, format: :json, user:{ picture: '123' }
      expect(user.reload.picture).not_to eq('123')
    end

    it "should not change invalid parameters" do
      user = authenticate
      put :update, format: :json, user:{ email: '123' }
      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe "GET #lookup" do

    it "requires the user to be authenticated as an editor" do
      get :lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:unauthorized)

      authenticate(:user)
      get :lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:forbidden)

      authenticate(:editor)
      get :lookup, :guess => "Scooby", :format => :json
      expect(response).to have_http_status(:success)
    end

    it "responds successfully with an HTTP 200 status code and some users" do
      authenticate(:editor)
      user = create(:user, name:'Scooby doo')
      get :lookup, :guess => "Scooby", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      # FIXME - this hash structure is kinda silly
      assert_equal response_json.first["sha"], user.sha
    end

    it "responds successfully with an HTTP 200 status code and no users" do
      authenticate(:editor)
      get :lookup, :guess => "blah", :format => :json

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      assert response_json.empty?
    end

  end

end
