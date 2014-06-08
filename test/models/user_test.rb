require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "reviewer_of?" do
    user = User.create!
    submitted_paper = Paper.new(:state => :submitted)
    Assignment.create(:paper => submitted_paper, :user => user, :role => "reviewer")
    assert user.reviewer_of?(submitted_paper)
    assert !user.author_of?(submitted_paper)
    assert !user.collaborator_on?(submitted_paper)
  end

  test "collaborator_on?" do
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    collaborator = User.create!
    Assignment.create(:paper => paper, :user => collaborator, :role => "collaborator")
    assert collaborator.collaborator_on?(paper)
    assert !collaborator.reviewer_of?(paper)
    assert !collaborator.author_of?(paper)
  end

  test "author_of?" do
    user = User.create!
    submitted_paper = Paper.new(:state => :submitted, :user => user)
    assert user.author_of?(submitted_paper)
    assert !user.reviewer_of?(submitted_paper)
    assert !user.collaborator_on?(submitted_paper)
  end
end
