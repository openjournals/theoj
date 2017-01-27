require "rails_helper"

describe PapersController do

  describe "GET #badge" do

    render_views

    it "WITHOUT USER responds successfully with an HTTP 200 status code and response" do
      paper = create(:paper, :review_completed)
      get :badge, identifier:paper.typed_provider_id, format:'html'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("text/html")
      expect(response.body).to include('completed.svg')
    end

    it "WITHOUT USER responds successfully with an HTTP 200 status code and JSON response" do
      paper = create(:paper, :review_completed)
      get :badge, identifier:paper.typed_provider_id, format:'json'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")
      expect(response_json).to eq('state'=>'review_completed')
    end

    it "Sets an eTag" do
      paper = create(:paper, :review_completed)
      get :badge, identifier:paper.typed_provider_id

      expect( response.header['ETag'] ).to be_present
    end

    it "Returns 304 if an etag is set" do
      paper = create(:paper, :review_completed)
      get :badge, identifier:paper.typed_provider_id

      etag1 = response['ETag']

      request.headers['If-None-Match'] = etag1

      get :badge, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:not_modified)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to be_blank
    end
  end


  describe "GET #history" do
    render_views

    it "WITH USER should stop a random editor from viewing a paper history" do
      paper_as_editor = create(:paper)
      paper = create(:paper)
      user = authenticate

      # Assign user as editor on a paper
      create(:assignment, :editor, paper: paper_as_editor, user: user)

      # User has no assignments on this paper so should not be able to view the history
      get :history, identifier: paper.typed_provider_id

      expect(response.status).to eq(403)
    end

    it "WITH USER should stop non-editor from viewing paper history" do
      paper = create(:paper)
      user = authenticate

      # Assign user as reviewer on a paper
      create(:assignment, :reviewer, paper: paper, user: user)

      # User is not editor of paper so should not be able to see the full history
      get :history, identifier: paper.typed_provider_id

      expect(response.status).to eq(403)
    end

    it "WITH USER should allow the editor to view the paper history" do
      paper = create(:paper)
      user = authenticate

      # Assign user as editor on a paper
      create(:assignment, :editor, paper: paper, user: user)

      # User is the editor so should be able to see the paper history
      get :history, identifier: paper.typed_provider_id, format:'html'

      expect(response.status).to eq(200)
    end

    it "WITH USER should allow any admin to view the paper history" do
      paper = create(:paper)
      user = authenticate
      user.admin = true; user.save

      # User is an admin so should be able to see the paper history
      get :history, identifier: paper.typed_provider_id, format:'html'

      expect(response.status).to eq(200)
    end
  end

end
