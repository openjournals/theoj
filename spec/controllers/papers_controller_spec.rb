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

end
