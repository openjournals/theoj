require "rails_helper"

describe AnnotationsController do

  shared_examples "a state change" do

    it "AS EDITOR responds successfully with a correct status and changed issue" do
      authenticate(:editor)

      paper = create(:paper, :under_review)
      issue = create(:issue, initial_state.to_sym, paper:paper)

      put method, paper_id:paper.sha, id:issue.id, format:'json'

      expect(response).to have_http_status(:success)
      expect(response_json).to include('state' => end_state)
      issue.reload
      expect(issue.state).to eq(end_state)
    end

    it "AS REVIEWER responds successfully with a correct status and changed issue" do
      user = authenticate

      paper = create(:paper, :under_review, reviewer:user)
      issue = create(:issue, initial_state.to_sym, paper:paper)

      user.reload

      put method, paper_id:paper.sha, id:issue.id, format:'json'

      expect(response).to have_http_status(:success)
      expect(response_json).to include('state' => end_state)
      issue.reload
      expect(issue.state).to eq(end_state)
    end

    it "AS USER responds successfully with a forbidden status" do
      authenticate

      paper = create(:paper, :under_review)
      issue = create(:issue, initial_state.to_sym, paper:paper)

      put method, paper_id:paper.sha, id:issue.id, format:'json'

      expect(response).to have_http_status(:forbidden)
      issue.reload
      expect(issue.state).not_to eq(end_state)
    end

    it "AS AUTHOR responds successfully with a forbidden status" do
      user = authenticate

      paper = create(:paper, :under_review, submittor:user)
      issue = create(:issue, initial_state.to_sym, paper:paper)

      put method, paper_id:paper.sha, id:issue.id, format:'json'

      expect(response).to have_http_status(:forbidden)
      issue.reload
      expect(issue.state).not_to eq(end_state)
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

end
