require "rails_helper"

describe AssignmentsController do

  describe "GET #index" do

    it "should return the list of reviewers" do
      paper = create(:paper)

      get :index, paper_id:paper.sha, format: :json

      expect(response.content_type).to eq("application/json")
      expect(response_json.length).to eq(1)
    end

  end

  describe "POST #create" do

    it "an unauthenticated user should be forbidden" do
      paper = create(:paper)

      post :create, paper_id:paper.sha, format: :json, user:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "an authenticated user should be forbidden" do
      authenticate
      paper = create(:paper)

      post :create, paper_id:paper.sha, format: :json, user:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "the submittor should be forbidden" do
      user = authenticate
      paper = create(:paper, submittor:user)

      post :create, paper_id:paper.sha, format: :json, user:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "a collaborator should be forbidden" do
      user = authenticate
      paper = create(:paper, collaborator:user)

      post :create, paper_id:paper.sha, format: :json, user:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "a reviewer should be forbidden" do
      user = authenticate
      paper = create(:paper, reviewer:user)

      post :create, paper_id:paper.sha, format: :json, user:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "the editor should be allowed to add reviewers" do
      authenticate(:editor)

      paper = create(:paper)

      reviewer = create(:user)
      post :create, paper_id:paper.sha, format: :json, user:reviewer.sha

      expect(response).to have_http_status(:success)
    end

    it "the editor should add a reviewer" do
      authenticate(:editor)

      paper = create(:paper)

      reviewer = create(:user)
      post :create, paper_id:paper.sha, format: :json, user:reviewer.sha

      expect(paper.reviewers.length).to eq(1)
      expect(paper.reviewers.first).to eq(reviewer)
    end

    it "the editor should return the list of reviewers" do
      set_paper_editor authenticate(:editor)

      paper = create(:paper)

      reviewer = create(:user)
      post :create, paper_id:paper.sha, format: :json, user:reviewer.sha

      expect(response.content_type).to eq("application/json")
      expect(response_json.length).to eq(3)
      expect(response_json.last['user']['sha']).to eq(reviewer.sha)
    end

    it "should fail if you add a reviewer that is the submittor" do
      authenticate(:editor)

      submittor = create(:user)
      paper = create(:paper, submittor:submittor)

      post :create, paper_id:paper.sha, format: :json, user:submittor.sha

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "should fail if you add a reviewer that is a collaborator" do
      authenticate(:editor)

      collaborator = create(:user)
      paper = create(:paper, collaborator:collaborator)

      post :create, paper_id:paper.sha, format: :json, user:collaborator.sha

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "should fail if you add a reviewer that is already a reviewer" do
      authenticate(:editor)

      reviewer = create(:user)
      paper = create(:paper, reviewer:reviewer)

      post :create, paper_id:paper.sha, format: :json, user:reviewer.sha

      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe "DELETE #destroy" do

    it "an unauthenticated user should be forbidden" do
      paper = create(:paper)

      delete :destroy, paper_id:paper.sha, format: :json, id:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "an authenticated user should be forbidden" do
      authenticate
      paper = create(:paper)

      delete :destroy, paper_id:paper.sha, format: :json, id:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "the submittor should be forbidden" do
      user = authenticate
      paper = create(:paper, submittor:user)

      delete :destroy, paper_id:paper.sha, format: :json, id:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "a collaborator should be forbidden" do
      user = authenticate
      paper = create(:paper, collaborator:user)

      delete :destroy, paper_id:paper.sha, format: :json, id:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "a reviewer should be forbidden" do
      user = authenticate
      paper = create(:paper, reviewer:user)

      delete :destroy, paper_id:paper.sha, format: :json, id:'abcd'

      expect(response).to have_http_status(:forbidden)
    end

    it "the editor should be allowed to remove reviewers" do
      authenticate(:editor)

      reviewer = create(:user)
      paper = create(:paper, reviewer:reviewer)

      delete :destroy, paper_id:paper.sha, format: :json, id:paper.reviewer_assignments.first.sha

      expect(response).to have_http_status(:success)
    end

    it "the editor should remove a reviewer" do
      authenticate(:editor)

      reviewer1 = create(:user)
      reviewer2 = create(:user)
      paper = create(:paper, reviewer:[reviewer1,reviewer2])

      delete :destroy, paper_id:paper.sha, format: :json, id:paper.reviewer_assignments.first.sha

      expect(paper.reviewers.length).to eq(1)
      expect(paper.reviewers.first).to eq(reviewer2)
    end

    it "the editor should return the list of reviewers" do
      set_paper_editor authenticate(:editor)

      reviewer1 = create(:user)
      reviewer2 = create(:user)
      paper = create(:paper, reviewer:[reviewer1,reviewer2])

      delete :destroy, paper_id:paper.sha, format: :json, id:paper.reviewer_assignments.first.sha

      expect(response.content_type).to eq("application/json")
      expect(response_json.length).to eq(3)
    end

    it "should fail if you remove a user that is not a reviewer" do
      authenticate(:editor)

      reviewer1 = create(:user)
      paper = create(:paper, reviewer:[reviewer1])

      delete :destroy, paper_id:paper.sha, format: :json, id:'some random sha'

      expect(response).to have_http_status(:unprocessable_entity)
    end

  end
  
end
