require "rails_helper"

describe PapersController do
  describe "GET #index" do
    it "AS ADMIN responds successfully with an HTTP 200 status code" do
      user = create(:admin)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :index, :format => :json
      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "GET #show" do
    it "AS USER without permissions" do
      user = create(:user)
      paper = create(:paper)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :show, :id => paper.sha, :format => :json

      expect(response.status).to eq(403)
    end
  end

  describe "GET #show" do
    it "AS REVIEWER (with permissions)" do
      user = create(:user)
      paper = create(:paper_under_review)
      create(:assignment_as_reviewer, :paper => paper, :user => user)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :show, :id => paper.sha, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "GET #show" do
    it "AS COLLABORATOR (with permissions)" do
      user = create(:user)
      paper = create(:paper_under_review)
      create(:assignment_as_collaborator, :paper => paper, :user => user)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :show, :id => paper.sha, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "GET #show" do
    it "AS AUTHOR (with permissions)" do
      user = create(:user)
      paper = create(:paper_under_review, :user => user)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :show, :id => paper.sha, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
    end
  end

  describe "GET #status" do
    render_views

    it "WITHOUT USER responds successfully with an HTTP 200 status code" do
      paper = create(:paper_under_review)
      get :status, :id => paper.sha, :format => :html

      etag1 = response.header['ETag']

      expect(response).to be_success
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("text/html")
      expect(response.body).to eq("under_review")

      paper.accept!

      get :status, :id => paper.sha, :format => :html

      etag2 = response.header['ETag']

      assert etag1 != etag2
      expect(response.body).to eq("accepted")
    end
  end

  describe "PUT #update" do
    it "AS AUTHOR on pending paper should change title" do
      user = create(:user)
      paper = create(:paper, :user => user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      put :update, :id => paper.sha, :format => :json, :paper => { :title => "Boo ya!"}

      expect(response).to be_success
      assert_equal hash_from_json(response.body)["paper"]["title"], "Boo ya!"
    end
  end

  describe "PUT #update" do
    it "AS AUTHOR responds on submitted paper should not change title" do
      user = create(:user)
      paper = create(:submitted_paper, :user => user, :title => "Hello space")
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      put :update, :id => paper.sha, :format => :json, :paper => { :title => "Boo ya!"}

      expect(response.status).to eq(403)
      assert_equal "Hello space", paper.title
    end
  end

  describe "PUT #accept" do
    it "AS EDITOR responds successfully with a correct status and accept paper" do
      user = create(:editor)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper = create(:paper_under_review)

      put :accept, :id => paper.sha, :format => :json

      expect(response).to be_success
      assert_equal hash_from_json(response.body)["paper"]["state"], "accepted"
    end
  end

  describe "PUT #accept" do
    it "AS USER responds successfully with a correct status (403) and NOT accept paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper = create(:paper_under_review)

      put :accept, :id => paper.sha, :format => :json

      # Should be redirected
      expect(response.status).to eq(403)
    end
  end

  describe "PUT #accept" do
    it "AS AUTHOR responds successfully with a correct status (403) and NOT accept paper" do
      user = create(:user)
      paper = create(:paper_under_review, :user => user)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      put :accept, :id => paper.sha, :format => :json

      expect(response.status).to eq(403)
    end
  end

  describe "GET #as_reviewer" do
    it "AS REVIEWER should return correct papers" do
      user = create(:user)
      paper = create(:paper_under_review)
      create(:assignment_as_reviewer, :user => user, :paper => paper)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :as_reviewer, :format => :json

      expect(response).to be_success
      assert_equal 1, hash_from_json(response.body)["papers"].size
    end
  end

  describe "GET #as_author" do
    it "AS REVIEWER should return correct papers" do
      user = create(:user)
      paper = create(:paper_under_review)
      create(:assignment_as_reviewer, :user => user, :paper => paper)

      # This is the one that should be returned
      user = create(:user)
      paper = create(:paper, :user => user)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :as_author, :format => :json

      expect(response).to be_success
      assert_equal 1, hash_from_json(response.body)["papers"].size
    end
  end

  describe "GET #as_editor" do
    it "AS EDITOR should return correct papers" do
      user = create(:editor)
      create(:paper_under_review) # should be returned
      create(:submitted_paper) # should be returned
      create(:paper) # pending (should not be returned)

      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :as_editor, :format => :json

      expect(response).to be_success
      assert_equal 2, hash_from_json(response.body)["papers"].size
    end
  end
end
