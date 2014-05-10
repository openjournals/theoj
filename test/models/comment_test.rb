require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # CREATE (as author)

  test "user CAN comment on their own paper" do
    user = User.create!
    owned_submitted_paper = Paper.new(:user => user, :state => :submitted)
    ability = Ability.new(user, owned_submitted_paper)
    assert ability.can?(:create, Comment.new(:paper_id => owned_submitted_paper))
  end

  # CREATE (as a user without privilege)

  test "user CANNOT comment on someone elses paper and are not a reviewer or editor" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.cannot?(:create, Comment.new(:paper => paper))
  end

  # CREATE (as a reviewer)

  test "user CAN comment on someone elses paper if they are a reviewer" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    Assignment.create(:user => user, :paper => paper)
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Comment.new(:paper => paper))
  end

  # CREATE (as an editor)

  test "user CAN comment on someone elses paper if they are an editor" do
    user = User.create!(:editor => true)
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Comment.new(:paper => paper))
  end

  # READ (as an author)

  test "user CAN read their own comments on their own paper" do
    author = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    comment = Comment.create(:paper => submitted_paper, :user => author)
    ability = Ability.new(author, submitted_paper, comment)
    assert ability.can?(:read, comment)
  end

  # READ (as an author)

  test "user CAN read someone else's comments on their own paper" do
    author = User.create!
    commentor = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    comment = Comment.create(:user => commentor, :paper => submitted_paper)
    ability = Ability.new(author, submitted_paper, comment)
    assert ability.can?(:read, comment)
  end

  # READ (as a user without privilege)

  test "user CANNOT read comments on paper that isn't their own" do
    author = User.create!
    reader = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    ability = Ability.new(reader, submitted_paper)
    comment = Comment.create(:user => author, :paper => submitted_paper)
    assert ability.cannot?(:read, comment)
  end

  # READ (as an editor)

  test "user CAN read comments on paper as an editor" do
    editor = User.create!(:editor => true)
    author = User.create!
    submitted_paper = Paper.new(:user => author, :state => :submitted)
    comment = Comment.create(:user => author)
    ability = Ability.new(editor, submitted_paper, comment)
    assert ability.can?(:read, comment)
  end

  # UPDATE (as an author)

  test "user CAN update their comments on their own paper provided there are no responses" do
    author = User.create!
    editor = User.create!(:editor => true)
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    comment_1 = Comment.create(:user => author, :paper => submitted_paper)
    comment_2 = Comment.create(:user => editor, :paper => submitted_paper, :parent_id => comment_1.id)
    ability = Ability.new(author, submitted_paper, comment_1)
    assert ability.cannot?(:update, comment_1)
  end

  # DELETE (as an author)

  test "user CANNOT delete their comments" do
    author = User.create!
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    comment_1 = Comment.create(:user => author, :paper => submitted_paper)
    ability = Ability.new(author, submitted_paper, comment_1)
    assert ability.cannot?(:destroy, comment_1)
  end

  # DELETE (as an editor)

  test "user CAN delete their comments if they are an editor" do
    author = User.create!
    editor = User.create!(:editor => true)
    submitted_paper = Paper.create!(:user => author, :state => :submitted)
    comment_1 = Comment.create(:user => editor, :paper => submitted_paper)
    ability = Ability.new(editor, submitted_paper, comment_1)
    assert ability.can?(:destroy, comment_1)
  end
end
