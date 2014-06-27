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
  
  describe "GET #status" do
    it "responds successfully with an HTTP 200 status code" do
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
end
