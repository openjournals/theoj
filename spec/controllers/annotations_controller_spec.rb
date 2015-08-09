require "rails_helper"

describe AnnotationsController do

  describe "POST #create" do

    it "should succeed" do
      user  = authenticate
      paper = create(:paper, :under_review, submittor:user)

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      expect(response).to have_http_status(:created)
      expect(response_json).to include(
                                   'paper_id'  => paper.id,
                                   'body'      => 'An issue',
                                   'parent_id' => nil,
                                   'responses' => []            )
    end

    it "should create a root annotation" do
      user  = authenticate
      paper = create(:paper, :under_review, submittor:user)

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      annotation = paper.annotations.reload.last
      expect(annotation).to have_attributes(
                                paper:      paper,
                                body:       'An issue',
                                assignment: paper.submittor_assignment,
                                parent:     nil
                            )
    end

    it "should succeed when create a response" do
      user  = authenticate
      paper = create(:paper, :under_review, submittor:user)
      root  = create(:annotation, paper:paper)

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { parent_id:root.id, body:'A response' }

      expect(response).to have_http_status(:created)
      expect(response_json).to include(
                                   'paper_id'  => paper.id,
                                   'body'      => 'A response',
                                   'parent_id' => root.id          )
    end

    it "should create a response" do
      user  = authenticate
      paper = create(:paper, :under_review, submittor:user)
      root  = create(:annotation, paper:paper)

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { parent_id:root.id, body:'A response' }

      annotation = paper.annotations.reload.last
      expect(annotation).to have_attributes(
                                paper:      paper,
                                body:       'A response',
                                assignment: paper.submittor_assignment,
                                parent:     root
                            )
    end

    it "should fail if the paper doesn't exist" do
      authenticate
      post :create, paper_identifier:'test:nonexistant',
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      expect(response).to have_http_status(:not_found)
    end

    it "should fail if no user is logged in" do
      paper = create(:paper, :under_review, submittor:create(:user))

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      expect(response).to have_http_status(:unauthorized)
      expect(paper.annotations.reload.count).to eq(0)
    end

    it "should fail if the user is not assigned to the paper" do
      user  = authenticate
      paper = create(:paper, :under_review, submittor:create(:user))

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      expect(response).to have_http_status(:forbidden)
      expect(paper.annotations.reload.count).to eq(0)
    end

    it "should fail if the paper is not under review" do
      user  = authenticate
      paper = create(:paper, :submitted, submittor:user)

      post :create, paper_identifier:paper.typed_provider_id,
                    annotation: { body:'An issue', page:1, xStart:0, yStart:0, xEnd:99, yEnd:99 }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(paper.annotations.reload.count).to eq(0)
    end

  end

  shared_examples "a state change" do

    it "AS EDITOR responds successfully with a correct status and changed issue" do
      authenticate(:editor)
      user = create(:user)

      paper = create(:paper, :under_review, submittor:user)
      issue = create(:issue, initial_state.to_sym, paper:paper, user:user)

      put method, paper_identifier:paper.typed_provider_id, id:issue.id

      expect(response).to have_http_status(:success)
      expect(response_json).to include('state' => end_state)
      expect(issue.reload.state).to eq(end_state)
    end

    it "Creating user responds successfully with a correct status and changed issue" do
      user = authenticate

      paper = create(:paper, :under_review, submittor:user)
      issue = create(:issue, initial_state.to_sym, paper:paper, user:user)

      put method, paper_identifier:paper.typed_provider_id, id:issue.id

      expect(response).to have_http_status(:success)
      expect(response_json).to include('state' => end_state)
      expect(issue.reload.state).to eq(end_state)
    end

    it "As a different user fails with a forbidden status" do
      user = authenticate
      creator = create(:user)

      paper = create(:paper, :under_review, submittor:creator, reviewer:user)
      issue = create(:issue, initial_state.to_sym, paper:paper, user:creator)

      put method, paper_identifier:paper.typed_provider_id, id:issue.id

      expect(response).to have_http_status(:forbidden)
      expect(issue.reload.state).to eq(initial_state)
    end

    it "When not logged in fails with a forbidden status" do
      creator = create(:user)

      paper = create(:paper, :under_review, submittor:creator)
      issue = create(:issue, initial_state.to_sym, paper:paper, user:creator)

      put method, paper_identifier:paper.typed_provider_id, id:issue.id

      expect(response).to have_http_status(:unauthorized)
      expect(issue.reload.state).to eq(initial_state)
    end

    it "When the paper is not under review it fails" do
      user = authenticate

      paper = create(:paper, :under_review, submittor:user)
      issue = create(:issue, initial_state.to_sym, paper:paper, user:user)
      paper.update_attributes!(state: 'submitted')

      put method, paper_identifier:paper.typed_provider_id, id:issue.id

      expect(response).to have_http_status(:unprocessable_entity)
      expect(issue.reload.state).to eq(initial_state)
    end

    it "fails if the annotation is a response" do
      user = authenticate

      paper = create(:paper, :under_review, submittor:user)
      issue = create(:issue, paper:paper)
      comment = create(:response, initial_state.to_sym, parent:issue, user:user)

      put method, paper_identifier:paper.typed_provider_id, id:comment.id

      expect(response).to have_http_status(:unprocessable_entity)
      expect(comment.reload.state).to eq(initial_state)
    end

  end

  describe "PUT #resolve" do
    let(:method)        { :resolve  }
    let(:initial_state) { 'unresolved'}
    let(:end_state)     { 'resolved' }
    it_behaves_like "a state change"
  end

  describe "PUT #dispute" do
    let(:method)        { :dispute  }
    let(:initial_state) { 'unresolved'}
    let(:end_state)     { 'disputed' }
    it_behaves_like "a state change"
  end

  describe "PUT #unresolved" do
    let(:method)        { :unresolve  }
    let(:initial_state) { 'resolved'}
    let(:end_state)     { 'unresolved' }
    it_behaves_like "a state change"
  end

  describe "GET #index" do

    it "only gets the issues" do
      submittor = authenticate
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :index, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:ok)
      expect(response_json.length).to eq(2)
    end

    it "returns nothing if the user is not assigned" do
      user = authenticate
      submittor = create(:user)
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :index, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:no_content)
      expect(response_json).to eq([])
    end

    it "returns nothing if the user is not authenticated" do
      submittor = create(:user)
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :index, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:no_content)
      expect(response_json).to eq([])
    end

  end

  describe "GET #all" do

    it "only gets the issues" do
      submittor = authenticate
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :all, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:ok)
      expect(response_json.length).to eq(4)
    end

    it "returns nothing if the user is not assigned" do
      user = authenticate
      submittor = create(:user)
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :all, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:no_content)
      expect(response_json).to eq([])
    end

    it "returns nothing if the user is not authenticated" do
      submittor = create(:user)
      paper = create(:paper, submittor:submittor)
      create_list(:response, 2, paper:paper)

      get :all, paper_identifier:paper.typed_provider_id

      expect(response).to have_http_status(:no_content)
      expect(response_json).to eq([])
    end

  end

end
