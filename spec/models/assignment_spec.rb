require "rails_helper"

describe Assignment do

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
    editor1 = set_editor
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
    create(:annotation, paper:p, assignment:a)

    expect(a.destroy).to be_falsey
    expect(a.errors).not_to be_empty
    expect(a).not_to be_destroyed
  end

end
