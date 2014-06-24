require "rails_helper"

describe Assignment do
  it "WITHOUT ROLE: should not be able to assign papers" do
    user_1 = create(:user)
    paper = create(:submitted_paper, :user => user_1)
    user_2 = create(:user)

    ability = Ability.new(user_1, paper)

    assert ability.cannot?(:create, Assignment.new(:paper => paper, :user => user_2))
  end

  it "AS EDITOR: should be able to assign papers" do
    editor = create(:editor)
    reviewer = create(:user)
    paper = create(:submitted_paper)

    ability = Ability.new(editor, paper)
    assert ability.can?(:create, Assignment.new(:paper => paper, :user => reviewer, :role => "reviewer"))
  end

  it "AS EDITOR: should be able to delete paper assignments" do
    editor = create(:editor)
    reviewer = create(:user)
    paper = create(:submitted_paper)
    assignment = create(:assignment_as_reviewer, :user => reviewer, :paper => paper)

    ability = Ability.new(editor)

    assert ability.can?(:destroy, assignment)
  end

  it "AS REVIEWER: should return correct assignments" do
    reviewer = create(:user)
    paper = create(:submitted_paper)
    assignment = create(:assignment_as_reviewer, :user => reviewer, :paper => paper)

    assert_includes reviewer.papers_as_reviewer, paper
    assert reviewer.papers_as_collaborator.empty?
  end

  it "AS COLLABORATOR: should return correct assignments" do
    collaborator = create(:user)
    paper = create(:submitted_paper)
    assignment = create(:assignment_as_collaborator, :user => collaborator, :paper => paper)

    assert_includes collaborator.papers_as_collaborator, paper
    assert collaborator.papers_as_reviewer.empty?
  end

  it "AS EDITOR: should return correct assignments" do
    paper = create(:submitted_paper)
    editor = create(:editor)
    create(:assignment_as_editor, :paper => paper, :user => editor)

    assert_includes editor.papers_as_editor, paper
  end
end
