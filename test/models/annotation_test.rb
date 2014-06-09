require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase
  # CREATE (as author)

  test "user CAN annotate their own paper" do
    user = User.create!
    owned_submitted_paper = Paper.new(:user => user, :state => :submitted)
    ability = Ability.new(user, owned_submitted_paper)
    assert ability.can?(:create, Annotation.new(:paper_id => owned_submitted_paper, :body => "Blah"))
  end

  # CREATE (as a user without privilege)

  test "user CANNOT annotate someone elses paper and are not a reviewer or editor" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.cannot?(:create, Annotation.new(:paper => paper, :body => "Blah"))
  end

  # CREATE (as a reviewer)

  test "user CAN annotate someone elses paper if they are a reviewer" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    Assignment.create(:user => user, :paper => paper, :role => "reviewer")
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Annotation.new(:paper => paper, :body => "Blah"))
  end

  # CREATE (as an editor)

  test "user CAN annotate someone elses paper if they are an editor" do
    user = User.create!(:editor => true)
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Annotation.new(:paper => paper, :body => "Blah"))
  end

  # READ (as an author)

  test "user CAN read their own annotates on their own paper" do
    author = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    annotation = Annotation.create(:paper => submitted_paper, :user => author, :body => "Blah")
    ability = Ability.new(author, submitted_paper, annotation)
    assert ability.can?(:read, annotation)
  end

  # READ (as an author)

  test "user CAN read someone else's comments on their own paper" do
    author = User.create!
    commentor = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    annotation = Annotation.create(:user => commentor, :paper => submitted_paper, :body => "Blah")
    ability = Ability.new(author, submitted_paper, annotation)
    assert ability.can?(:read, annotation)
  end

  # READ (as a user without privilege)

  test "user CANNOT read comments on paper that isn't their own" do
    author = User.create!
    reader = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    ability = Ability.new(reader, submitted_paper)
    annotation = Annotation.create(:user => author, :paper => submitted_paper, :body => "Blah")
    assert ability.cannot?(:read, annotation)
  end

  # READ (as an editor)

  test "user CAN read comments on paper as an editor" do
    editor = User.create!(:editor => true)
    author = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    annotation = Annotation.create(:user => author, :body => "Blah")
    ability = Ability.new(editor, submitted_paper, annotation)
    assert ability.can?(:read, annotation)
  end

  # UPDATE (as an author)

  test "user CAN update their annotation on their own paper provided there are no responses" do
    author = User.create!
    editor = User.create!(:editor => true)
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    annotation_1 = Annotation.create(:user => author, :paper => submitted_paper, :body => "Blah")
    annotation_2 = Annotation.create(:user => editor, :paper => submitted_paper, :parent_id => annotation_1.id, :body => "Blah")
    ability = Ability.new(author, submitted_paper, annotation_1)
    assert ability.cannot?(:update, annotation_1)
  end

  # DELETE (as an author)

  test "user CANNOT delete their comments" do
    author = User.create!
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    annotation_1 = Annotation.create(:user => author, :paper => submitted_paper, :body => "Blah")
    ability = Ability.new(author, submitted_paper, annotation_1)
    assert ability.cannot?(:destroy, annotation_1)
  end

  # DELETE (as an editor)

  test "user CAN delete their comments if they are an editor" do
    author = User.create!
    editor = User.create!(:editor => true)
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    annotation_1 = Annotation.create(:user => editor, :paper => submitted_paper, :body => "Blah")
    ability = Ability.new(editor, submitted_paper, annotation_1)
    assert ability.can?(:destroy, annotation_1)
  end
end
