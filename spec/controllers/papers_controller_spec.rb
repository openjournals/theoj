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
    it "AS USER responds successfully with a correct status and NOT accept paper" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      paper = create(:paper_under_review)

      put :accept, :id => paper.sha, :format => :json
      
      expect(response.status).to eq(403)
    end
  end
end
