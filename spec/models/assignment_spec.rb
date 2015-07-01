require "rails_helper"

describe Assignment do

  let(:arxiv_doc) do
    {
        provider_type:     :arxiv,
        provider_id:       "1311.1653",
        version:           2,
        authors:           "Mar Álvarez-Álvarez, Angeles I. Díaz",
        document_location: "http://arxiv.org/pdf/1311.1653v2.pdf",
        title:             "A photometric comprehensive study of circumnuclear star forming rings: the sample",
        summary:           "We present photometry.*in a second paper."
    }
  end

  it "WITHOUT ROLE: should not be able to assign papers" do
    user_1 = create(:user)
    paper  = create(:paper, :submitted, submittor:user_1)
    user_2 = create(:user)

    ability = Ability.new(user_1, paper)

    assert ability.cannot?(:create, Assignment.new(paper:paper, user:user_2) )
  end

  it "AS EDITOR: should be able to assign papers" do
    editor = create(:editor)
    reviewer = create(:user)
    paper = create(:paper, :submitted)

    ability = Ability.new(editor, paper)
    assert ability.can?(:create, Assignment.new(:paper => paper, :user => reviewer, :role => "reviewer"))
  end

  it "AS EDITOR: should be able to delete paper assignments" do
    editor = create(:editor)
    reviewer = create(:user)
    paper = create(:paper, :submitted)
    assignment = create(:assignment, :reviewer, user:reviewer, paper:paper)

    ability = Ability.new(editor)

    assert ability.can?(:destroy, assignment)
  end

  it "AS REVIEWER: should return correct assignments" do
    reviewer = create(:user)
    paper = create(:paper, :submitted)
    assignment = create(:assignment, :reviewer, user:reviewer, paper:paper)

    assert_includes reviewer.papers_as_reviewer, paper
    assert reviewer.papers_as_collaborator.empty?
  end

  it "AS COLLABORATOR: should return correct assignments" do
    collaborator = create(:user)
    paper = create(:paper, :submitted)
    assignment = create(:assignment, :collaborator, user:collaborator, paper:paper)

    assert_includes collaborator.papers_as_collaborator, paper
    assert collaborator.papers_as_reviewer.empty?
  end

  it "AS EDITOR: should be editor for all papers" do
    editor1 = set_paper_editor
    editor2 = create(:editor)
    paper = create(:paper, :submitted)
    paper = create(:paper, :submitted)

    expect(editor1.papers_as_editor.length).to eq(2)
    expect(editor2.papers_as_editor.length).to eq(0)
  end

  it "should not delete assignments if the they are used in associations" do
    p = create(:paper)
    a = create(:assignment, paper:p)

    expect(a.destroy).to be_truthy
    expect(a.errors).to be_empty
    expect(a).to be_destroyed
  end

  it "should not delete assignments if the they are used in associations" do
    p = create(:paper)
    a = create(:assignment, paper:p)
    p.assignments.reload

    create(:annotation, paper:p, assignment:a)

    expect(a.destroy).to be_falsey
    expect(a.errors).not_to be_empty
    expect(a).not_to be_destroyed
  end

  describe "emails" do

    it "sends an email to the editor" do
      user   = create(:user, name:'John Smith', email:'jsmith@example.com')
      editor = set_paper_editor( create(:user, email:'editor@example.com') )
      expect {
        create(:paper, title:'My Paper', submittor:user)
      }.to change { deliveries.size }.by(2)

      is_expected.to have_sent_email.to('editor@example.com').matching_subject(/Paper Assigned/).matching_body(/as an editor/)
    end

    it "sends an email when a user is assigned" do
      user   = create(:user, name:'John Smith', email:'jsmith@example.com')
      paper = create(:paper, title:'My Paper', submittor:user)

      reviewer = create(:user, email:'reviewer@example.com')
      expect {
        paper.add_assignee(reviewer)
      }.to change { deliveries.size }.by(1)

      is_expected.to have_sent_email.to('reviewer@example.com').matching_subject(/Paper Assigned/).matching_body(/as a reviewer/)
    end

    it "sends emails when a paper is updated" do
      user     = create(:user, name:'John Smith', email:'jsmith@example.com')
      editor   = set_paper_editor( create(:user, email:'editor@example.com') )
      reviewer = create(:user, email:'reviewer@example.com')
      original = create(:paper, title:'My Paper', submittor:user, arxiv_id:'1311.1653', version:1, submittor:user)
      original.add_assignee(reviewer)
      original.reload
      deliveries.clear

      expect {
        original.create_updated!(arxiv_doc)
      }.to change { deliveries.size }.by(3)

      is_expected.to have_sent_email.to('editor@example.com').matching_subject(/Paper Updated/)
      is_expected.to have_sent_email.to('reviewer@example.com').matching_subject(/Paper Updated/)
    end

    it "sends the correct emails when a user is assigned after the paper is updated" do
      user     = create(:user, name:'John Smith', email:'jsmith@example.com')
      editor   = set_paper_editor( create(:user, email:'editor@example.com') )
      original = create(:paper, title:'My Paper', submittor:user, arxiv_id:'1311.1653', version:1, submittor:user)
      updated  = original.create_updated!(arxiv_doc)
      deliveries.clear

      reviewer = create(:user, email:'reviewer@example.com')
      expect {
        updated.add_assignee(reviewer)
      }.to change { deliveries.size }.by(1)

      is_expected.to have_sent_email.to('reviewer@example.com').matching_subject(/Paper Assigned/)
    end

  end

  describe "#public" do

    it "should set the initial value based on the role" do
      expect( create(:assignment, role:'editor').public).to be_truthy
      expect( create(:assignment, role:'submittor').public).to be_truthy
      expect( create(:assignment, role:'collaborator').public).to be_truthy
      expect( create(:assignment, role:'reviewer').public).to be_falsy
    end

  end

  describe "#make_user_info_public?" do

    it "should make editor info public" do
      any_user = create(:user)

      assignment = create(:assignment, role:'editor')
      expect( assignment.make_user_info_public?(any_user) ).to be_truthy
    end

    it "should make submittor and collaborator info public" do
      any_user = create(:user)

      assignment = create(:assignment, role:'submittor')
      expect( assignment.make_user_info_public?(any_user) ).to be_truthy
      assignment = create(:assignment, role:'collaborator')
      expect( assignment.make_user_info_public?(any_user) ).to be_truthy
    end

    it "reviewer info should not be public" do
      any_user = create(:user)

      assignment = create(:assignment, role:'reviewer')
      expect( assignment.make_user_info_public?(any_user) ).to be_falsy
    end

    it "info should be available to the assigned user" do
      user = create(:user)

      assignment = create(:assignment, role:'reviewer', user:user)
      expect( assignment.make_user_info_public?(user) ).to be_truthy
    end

    it "info should be available to the editor" do
      editor = create(:editor)
      assignment = create(:assignment, role:'reviewer')
      assignment.paper.assignments.create!(user:editor, role:'editor')

      expect( assignment.make_user_info_public?(editor) ).to be_truthy
    end

  end

  describe "#use_completed?" do

    it "only reviewers should use completed" do
      expect( create(:assignment, role:'reviewer').use_completed?).to be_truthy
      expect( create(:assignment, role:'submittor').use_completed?).to be_falsy
      expect( create(:assignment, role:'collaborator').use_completed?).to be_falsy
      expect( create(:assignment, role:'editor').use_completed?).to be_falsy
    end

  end

end
