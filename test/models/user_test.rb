require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  # ======================
  # = Paper CRUD actions =
  # ======================

  # CREATE
  
  test "user CAN create a paper" do
    user = User.create!
    ability = Ability.new(user)
    assert ability.can?(:create, Paper.create!(:user_id => user.id))
  end
  
  test "user CAN read their own paper" do
    user = User.create!
    owned_paper = Paper.new(:user => user) 
    ability = Ability.new(user, owned_paper)
    assert ability.can?(:read, owned_paper)
  end
  
  test "user CAN only destroy paper they own" do
    user = User.create!
    owned_paper = Paper.new(:user => user) 
    ability = Ability.new(user, owned_paper)
    assert ability.can?(:destroy, owned_paper)
  end
  
  test "user CANNOT destroy paper that's submitted" do
    user = User.create!
    owned_submitted_paper = Paper.new(:user => user, :state => :submitted) 
    ability = Ability.new(user, owned_submitted_paper)
    assert ability.cannot?(:destroy, owned_submitted_paper)
  end
  
  test "user CAN comment on their own paper" do
    user = User.create!
    owned_submitted_paper = Paper.new(:user => user, :state => :submitted) 
    ability = Ability.new(user, owned_submitted_paper)
    assert ability.can?(:create, Comment.new(:paper_id => owned_submitted_paper))
  end
  
  test "user CANNOT comment on someone elses paper and are not a reviewer or editor" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.cannot?(:create, Comment.new(:paper => paper))
  end
  
  test "user CAN comment on someone elses paper if they are a reviewer" do
    user = User.create!
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    Assignment.create(:user => user, :paper => paper)
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Comment.new(:paper => paper))
  end
  
  test "user CAN comment on someone elses paper if they are an editor" do
    user = User.create!(:editor => true)
    owning_user = User.create!
    paper = Paper.new(:user => owning_user)
    ability = Ability.new(user, paper)
    assert ability.can?(:create, Comment.new(:paper => paper))
  end
end
