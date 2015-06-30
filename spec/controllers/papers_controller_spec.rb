require "rails_helper"

describe PapersController do

  let(:arxiv_doc) {
    {
        provider_type: :arxiv,
        provider_id:   "1311.1653",
        version:       2,
        author_list:   "Mar Álvarez-Álvarez, Angeles I. Díaz",
        location:      "http://arxiv.org/pdf/1311.1653v2.pdf",
        title:         "A photometric comprehensive study of circumnuclear star forming rings: the sample",
        summary:       "We present photometry.*in a second paper."
    }
  }

  describe "GET #index" do

    it "As a user returns a list of your own papers" do
      user = authenticate
      create(:paper, submittor:user)

      get :index, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")
      expect(response_json.size).to be(1)
    end

    it "AS NO USER responds successfully with an HTTP 200 status code but an empty body" do
      create(:paper)

      get :index, :format => :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")
      expect(response_json.size).to be(0)
    end

  end

  describe "GET #show" do

    it "AS USER without permissions" do
      authenticate
      paper = create(:paper)

      get :show, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:forbidden)
    end

    it "AS REVIEWER (with permissions)" do
      user = authenticate
      paper = create(:paper, :under_review)
      create(:assignment, :reviewer, paper:paper, user:user)

      get :show, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      assert_serializer FullPaperSerializer
    end

    it "AS COLLABORATOR (with permissions)" do
      user = authenticate
      paper = create(:paper, :under_review)
      create(:assignment, :collaborator, paper:paper, user:user)

      get :show, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      assert_serializer FullPaperSerializer
    end

    it "AS AUTHOR (with permissions)" do
      user = authenticate
      paper = create(:paper, :under_review, submittor:user)

      get :show, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:success)
      expect(response.status).to eq(200)
      expect(response.content_type).to eq("application/json")
      assert_serializer FullPaperSerializer
    end

  end

  xdescribe "GET #arxiv_details" do

    let(:arxiv_response) do
      {
          "arxiv_url"        => "http://arxiv.org/abs/1111.1111v1",
          "created_at"       => "2011-11-04T12:50:44.000+00:00",
          "updated_at"       => "2011-11-04T12:50:44.000+00:00",
          "title"            => "Electronic structure of nickelates: From two-dimensional heterostructures to three-dimensional bulk materials",
          "summary"          => "Reduced dimensionality and strong electronic correlations, which are among the most important ...",
          "comment"          => "8 pages, 9 figures",
          "primary_category" => {"abbreviation" => "cond-mat.str-el"},
          "categories"       => [ {"abbreviation" => "cond-mat.str-el"} ],
          "authors"          => [ {"name" => "P. Hansmann", "affiliations" => []},
                                  {"name" => "K. Held",     "affiliations" => []}  ],
          "links"            => [ {"url"  => "http://dx.doi.org/10.1103/PhysRevB.82.235123", "content_type" => ""},
                                  {"url"  => "http://arxiv.org/abs/1111.1111v1",             "content_type" => "text/html"},
                                  {"url"  => "http://arxiv.org/pdf/1111.1111v1",             "content_type" => "application/pdf"} ]
      }
    end

    it "should fail if no user is logged in" do
      expect(Arxiv).not_to receive(:get)

      get :arxiv_details, :id => '1234.5678', :format => :json

      expect(response).to have_http_status(:unauthorized)
      expect(response_json).to eq(error_json(:unauthorized))
    end

    it "should attempt to fetch the response from the database" do
      authenticate
      paper = build(:paper, sha:'1234abcd'*8)
      expect(Paper).to receive(:find_by_arxiv_id).with('1234.5678').and_return( paper )
      expect(Arxiv).not_to receive(:get)

      get :arxiv_details, :id => '1234.5678', :format => :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")
      expect(response_json).to include("arxiv_url"   => "http://example.com/1234",
                                       "authors"     => "John Smith, Paul Adams, Ella Fitzgerald",
                                       "links"       => [{"url"=>"http://example.com/1234", "content_type"=>"application/pdf"}],
                                       "sha"         => '1234abcd'*8,
                                       "summary"     => "Summary of my awesome paper",
                                       "title"       => "My awesome paper"
                               )
    end

    it "should return a source field if the response is from the database" do
      authenticate
      paper = build(:paper)
      expect(Paper).to receive(:find_by_arxiv_id).with('1234.5678').and_return(paper)

      get :arxiv_details, :id => '1234.5678', :format => :json

      expect(response_json).to include("source" => "theoj")
    end

    it "should fetch the paper from Arxiv if it is not in the database" do
      authenticate
      expect(Paper).to receive(:find_by_arxiv_id).and_return(nil)
      expect(Arxiv).to receive(:get).with('1234.5678').and_return(arxiv_response)

      get :arxiv_details, :id => '1234.5678', :format => :json

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")

      expect(response_json).to eq(arxiv_response)
      expect(response_json).not_to include('source')
      expect(response_json).not_to include('self_owned')
    end

    it "should return a 404 if the paper is not found on Arxiv or the DB" do
      authenticate

      expect(Paper).to receive(:find_by_arxiv_id).and_return(nil)
      expect(Arxiv).to receive(:get).and_raise(Arxiv::Error::ManuscriptNotFound)

      get :arxiv_details, :id => '1234.5678', :format => :json

      expect(response).to have_http_status(:not_found)
    end

  end

  describe "GET #state" do

    render_views

    it "WITHOUT USER responds successfully with an HTTP 200 status code and response" do
      paper = create(:paper, :review_completed)
      get :state, identifier:paper.typed_provider_id, format:'html'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("text/html")
      expect(response.body).to include('completed.svg')
    end

    it "WITHOUT USER responds successfully with an HTTP 200 status code and JSON response" do
      paper = create(:paper, :review_completed)
      get :state, identifier:paper.typed_provider_id, format:'json'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json")
      expect(response_json).to eq('state'=>'review_completed')
    end

    it "Sets an eTag" do
      paper = create(:paper, :review_completed)
      get :state, identifier:paper.typed_provider_id

      expect( response.header['ETag'] ).to be_present
    end

    it "Returns 304 if an etag is set" do
      paper = create(:paper, :review_completed)
      get :state, identifier:paper.typed_provider_id

      etag1 = response['ETag']

      request.headers['If-None-Match'] = etag1

      get :state, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:not_modified)
      expect(response.content_type).to eq("application/json")
      expect(response.body).to be_blank
    end

  end

  xdescribe "POST #create" do

    before do
      @arxiv_request = stub_request(:get,  "http://export.arxiv.org/api/query?id_list=1401.0003").
                                   to_return(body: fixture("arxiv/1401.0003.xml"))
    end

    it "should create the paper" do
      authenticate

      expect {
        post :create, :format => :json, arxiv_id: '1401.0003'
      }.to change{Paper.count}.by(1)

      new = Paper.last
      expect( new.arxiv_id ).to eq('1401.0003')
    end

    it "should retrieve the Arxiv data" do
      authenticate

      post :create, :format => :json, arxiv_id: '1401.0003'

      expect(@arxiv_request).to have_been_made
      new = Paper.last
      expect( new.title    ).to start_with('Serendipitous')
    end

    it "should set the papers submittor" do
      authenticate

      post :create, :format => :json, arxiv_id: '1401.0003'

      new = Paper.last
      expect( new.submittor ).to eq(current_user)
    end

    it "should return a created status code" do
      authenticate

      post :create, :format => :json, arxiv_id: '1401.0003'

      expect(response).to have_http_status(:created)
    end

    it "should return a created status code" do
      authenticate

      post :create, :format => :json, arxiv_id: '1401.0003'

      assert_serializer FullPaperSerializer

      expect(response_json).to include(
                                   "location" => "http://arxiv.org/pdf/1401.0003v1.pdf",
                                   "sha"       => Paper.last.sha
                               )
    end

    it "should fail if the user is not authenticated" do
      post :create, :format => :json, arxiv_id: '1401.0003'

      expect(response).to have_http_status(:unauthorized)
    end

  end

  # describe "PUT #update" do
  #
  #   it "AS AUTHOR on submitted paper should change title" do
  #     user = authenticate
  #     paper = create(:paper, submittor:user)
  #
  #     put :update, identifier:paper.typed_provider_id, paper:{ title:"Boo ya!"}
  #
  #     expect(response).to have_http_status(:success)
  #     assert_equal response_json["title"], "Boo ya!"
  #   end
  #
  #   it "AS AUTHOR responds on submitted paper should not change title" do
  #     user = authenticate
  #     paper = create(:paper, :submitted, submittor:user, title:'Hello space')
  #
  #     put :update, identifier:paper.typed_provider_id, paper:{ title:"Boo ya!"}
  #
  #     expect(response.status).to eq(:forbidden)
  #     assert_equal "Hello space", paper.title
  #   end
  #
  # end

  describe "DELETE #destroy" do

    it "should delete the paper" do
      user = authenticate(:editor)
      paper = create(:paper)

      delete :destroy, identifier:paper.typed_provider_id

      expect( Paper.find_by_id(paper.id)).to be_nil
    end

    it "should return the correct html and status code" do
      user = authenticate(:editor)
      paper = create(:paper)

      delete :destroy, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:success)
    end

    it "should delete all versions of the paper" do
      user = authenticate(:editor)
      original = create(:paper, arxiv_id:'1311.1653', version:1)
      updated  = original.create_updated!(arxiv_doc)

      delete :destroy, identifier:updated.typed_provider_id

      expect( Paper.find_by_id(original.id)).to be_nil
      expect( Paper.find_by_id(updated.id)).to be_nil
    end

    it "should fail if the paper is not in the submitted state" do
      user = authenticate(:editor)
      paper = create(:paper, :under_review)

      delete :destroy, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:unprocessable_entity)
      expect( Paper.find_by_id(paper.id)).not_to be_nil
    end

    it "should fail if the user is not an editor" do
      user = authenticate(:user)
      paper = create(:paper, submittor:user)

      delete :destroy, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:forbidden)
      expect( Paper.find_by_id(paper.id)).not_to be_nil
    end

  end

  describe "PUT #transition" do

    it "AS EDITOR responds successfully with a correct status and accept paper" do
      authenticate(:editor)
      paper = create(:paper, :review_completed)

      put :transition, identifier:paper.typed_provider_id, transition: :accept

      expect(response).to have_http_status(:success)
      assert_equal response_json["state"], "accepted"
    end

    it "AS EDITOR responds with an unprocessable entity for an invalid transition" do
      authenticate(:editor)
      paper = create(:paper, :submitted)

      put :transition, identifier:paper.typed_provider_id, transition: :accept

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "AS USER responds successfully with a correct status (403) and NOT accept paper" do
      authenticate
      paper = create(:paper, :under_review)

      put :transition, identifier:paper.typed_provider_id, transition: :accept

      # Should be redirected
      expect(response).to have_http_status(:forbidden)
    end

    it "AS AUTHOR responds successfully with a correct status (403) and NOT accept paper" do
      user = authenticate
      paper = create(:paper, :under_review, submittor:user)

      put :transition, identifier:paper.typed_provider_id, transition: :accept

      expect(response).to have_http_status(:forbidden)
      expect(response_json).to eq(error_json(:forbidden))
    end

  end

  describe "POST #complete" do

    it "responds successfully with a correct status and paper" do
      user = authenticate
      paper = create(:paper, :under_review, reviewer:user)

      post :complete, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:success)
      expect(response_json["state"]).to eq("review_completed")
      expect(response_json['assigned_users'].second['completed']).to be_truthy
    end

    it "updates the assignment and paper" do
      user = authenticate
      paper = create(:paper, :under_review, reviewer:user)

      post :complete, identifier:paper.typed_provider_id

      expect(paper.reviewer_assignments.reload.first.completed).to be_truthy
    end

    it "should fail if the user is not authorized" do
      user = authenticate
      paper = create(:paper, :under_review, reviewer:true)

      post :complete, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:forbidden)
    end

    it "should fail if the paper could not be updated for some reason" do
      user = authenticate
      paper = create(:paper, :submitted, reviewer:user)

      post :complete, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:unprocessable_entity)
    end

  end

  describe "POST or DELETE #public" do

    context "with a POST" do

      it "it responds successfully with a correct status and paper" do
        user = authenticate
        paper = create(:paper, reviewer:user)

        post :public, identifier:paper.typed_provider_id

        expect(response).to have_http_status(:success)
        expect(response_json['assigned_users'].last['public']).to be_truthy
      end

      it "updates the assignment and paper" do
        user = authenticate
        paper = create(:paper, :under_review, reviewer:user)

        post :public, identifier:paper.typed_provider_id

        expect(paper.reviewer_assignments.reload.last.public).to be_truthy
      end

    end

    context "with a DELETE" do

      it "it responds successfully with a correct status and paper" do
        user = authenticate
        paper = create(:paper, reviewer:user)
        paper.reviewer_assignments.last.update_attributes(public:true)

        delete :public, identifier:paper.typed_provider_id

        expect(response).to have_http_status(:success)
        expect(response_json['assigned_users'].last['public']).to be_falsy
      end

      it "updates the assignment and paper" do
        user = authenticate
        paper = create(:paper, :under_review, reviewer:user)
        paper.reviewer_assignments.last.update_attributes(public:true)

        delete :public, identifier:paper.typed_provider_id

        expect(paper.reviewer_assignments.reload.last.public).to be_falsy
      end

    end

    it "should fail if the user is not authorized" do
      user = authenticate
      paper = create(:paper, :under_review, reviewer:true)

      post :public, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:forbidden)
    end

  end

  describe "PUT #check_for_update" do

    it "should create an updated paper" do
      user  = authenticate
      paper = create(:paper, submittor:user, arxiv_id:'1311.1653')
      stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653").to_return(fixture('arxiv/1311.1653v2.xml'))

      expect {
        put :check_for_update, identifier:paper.typed_provider_id
      }.to change{Paper.count}.by(1)

      expect(response).to have_http_status(:created)
      expect(response.content_type).to eq("application/json")
      assert_serializer PaperSerializer
      expect(response_json['provider_id']).to eq('1311.1653')
      expect(response_json['version']).to eq(2)
    end

    it "should fail if the user is not authenticated" do
      put :check_for_update, identifier:'arxiv:0000.0000'
      expect(response).to have_http_status(:unauthorized)
    end

    it "should fail if the authenticated user is not the submittor" do
      user  = create(:user)
      authenticate
      paper = create(:paper, submittor:user, arxiv_id:'1311.1653')

      put :check_for_update, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:forbidden)
    end

    it "should fail if there is no original paper" do
      user  = authenticate

      put :check_for_update, identifier:'arxiv:0000.0000'

      expect(response).to have_http_status(:not_found)
    end

    it "should fail if there is no new version" do
      user  = authenticate
      paper = create(:paper, submittor:user, arxiv_id:'1311.1653', version:2)
      stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653").to_return(fixture('arxiv/1311.1653v2.xml'))

      put :check_for_update, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:conflict)
    end

    it "should fail if the original version cannot be superceded" do
      user  = authenticate
      paper = create(:paper, :accepted, submittor:user, arxiv_id:'1311.1653')

      put :check_for_update, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:conflict)
    end

    it "should fail if there is no document on Arxiv" do
      user  = authenticate
      paper = create(:paper, submittor:user, arxiv_id:'1311.1653')
      stub_request(:get, "http://export.arxiv.org/api/query?id_list=1311.1653").to_return(fixture('arxiv/not_found.xml'))

      put :check_for_update, identifier:paper.typed_provider_id

      expect(response).to have_http_status(:not_found)
    end

  end

  describe "GET #versions" do

    it "returns a list of papers" do
      create(:paper, arxiv_id:'1234.5678', version:1)
      create(:paper, arxiv_id:'1234.5678', version:2)

      get :versions, identifier:'arxiv:1234.5678'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")
      assert_serializer BasicPaperSerializer

      expect(response_json.length).to eq(2)
    end

  end

  describe "GET #as_reviewer" do

    it "should return papers" do
      user = authenticate
      paper = create(:paper, :under_review, reviewer:user)

      get :as_reviewer, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(1)
    end

    it "should not return inactive papers" do
      user = authenticate
      paper = create(:paper, :superceded, reviewer:user)

      get :as_reviewer, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(0)
    end

    context "with a state" do

      it "should return correct papers" do
        user = authenticate
        paper = create(:paper, :under_review, reviewer:user)

        get :as_reviewer, :format => :json, :state => 'submittted'

        expect(response).to have_http_status(:success)
        expect(response_json.size).to be(0)
      end

    end

  end

  describe "GET #as_collaborator" do

    it "should return papers" do
      user = authenticate
      paper = create(:paper, :under_review, collaborator:user)

      get :as_collaborator, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(1)
    end

    it "should not return inactive papers" do
      user = authenticate
      paper = create(:paper, :superceded, collaborator:user)

      get :as_collaborator, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(0)
    end

    context "with a state" do

      it "should return correct papers" do
        user = authenticate
        paper = create(:paper, :superceded, collaborator:user)

        get :as_collaborator, :format => :json, :state => 'submittted'

        expect(response).to have_http_status(:success)
        expect(response_json.size).to be(0)
      end

    end

  end

  describe "GET #as_author" do

    it "should return papers" do
      user  = authenticate
      paper1 = create(:paper, :under_review, reviewer:user)
      # This is the one that should be returned
      paper2 = create(:paper, :under_review, submittor:user)

      get :as_author, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(1)
    end

    it "should not return inactive papers" do
      user  = authenticate
      paper1 = create(:paper, :under_review, reviewer:user)
      paper2 = create(:paper, :superceded,   submittor:user)

      get :as_author, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(0)
    end

  end

  describe "GET #as_editor" do

    it "should return papers" do
      user = set_paper_editor( authenticate(:editor) )
      create(:paper, :under_review) # should be returned
      create(:paper, :submitted)    # should be returned

      get :as_editor, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(2)
    end

    it "should not return inactive papers" do
      user = set_paper_editor( authenticate(:editor) )
      p1 = create(:paper, :under_review) # should be returned
      p2 = create(:paper, :superceded)   # should not be returned

      get :as_editor, :format => :json

      expect(response).to have_http_status(:success)
      expect(response_json.size).to be(1)
      expect(response_json.first['sha']).to eq(p1.sha)
    end

  end

end
