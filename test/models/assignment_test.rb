require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  # Abilities

  # CREATE (as author)
  test "user CANNOT assign papers" do
    user = User.create!
    user2 = User.create!
    owned_submitted_paper = Paper.new(:user => user, :state => :submitted)
    ability = Ability.new(user, owned_submitted_paper)
    assert ability.cannot?(:create, Assignment.new(:paper => owned_submitted_paper, :user => user2))
  end

  # CREATE (as editor)
  test "user CAN assign papers" do
    editor = User.create!(:editor => true)
    user = User.create!
    submitted_paper = Paper.new(:user => user, :state => :submitted)
    ability = Ability.new(editor, submitted_paper)
    assert ability.can?(:create, Assignment.new(:paper => submitted_paper, :user => user))
  end

  # DELETE (as editor)
  test "user CAN DELETE paper assignments" do
    editor = User.create!(:editor => true)
    user = User.create!
    submitted_paper = Paper.new(:user => user, :state => :submitted)
    assignment = Assignment.create!(:paper => submitted_paper, :user => user)
    ability = Ability.new(editor)
    assert ability.can?(:destroy, assignment)
  end

  # Assignment behaviours
  # papers_as_reviewer
  test "user author assignments" do
    paper = Paper.create!(:state => :submitted)
    reviewer = User.create!
    Assignment.create!(:user => reviewer, :paper => paper, :role => "reviewer")
    assert_includes reviewer.papers_as_reviewer, paper
    assert reviewer.papers_as_collaborator.empty?
  end

  # papers_as_collaborator
  test "user collaborator assignments" do
    paper = Paper.create!(:state => :submitted)
    collaborator = User.create!
    Assignment.create!(:user => collaborator, :paper => paper, :role => "collaborator")
    assert_includes collaborator.papers_as_collaborator, paper
    assert collaborator.papers_as_reviewer.empty?
  end

  # papers_as_editor
  test "user editor assignments" do
    paper = Paper.create!(:state => :submitted)
    editor = User.create!(:editor => true)
    Assignment.create!(:user => editor, :paper => paper, :role => "editor")
    assert_includes editor.papers_as_editor, paper
  end
end
