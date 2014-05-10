require 'test_helper'

class PaperTest < ActiveSupport::TestCase
  # CREATE (as author)

  test "user CAN create a paper" do
    user = User.create!
    ability = Ability.new(user)
    assert ability.can?(:create, Paper.create!(:user_id => user.id))
  end

  # READ (as author)

  test "user CAN read their own paper" do
    user = User.create!
    owned_paper = Paper.new(:user => user)
    ability = Ability.new(user, owned_paper)
    assert ability.can?(:read, owned_paper)
  end

  # UPDATE (as author)

  test "user CAN update their own paper if it's not submitted" do
    user = User.create!
    owned_paper = Paper.new(:user => user)
    ability = Ability.new(user, owned_paper)
    assert ability.can?(:update, owned_paper)
  end

  test "user CAN update their own paper if it's submitted" do
    user = User.create!
    owned_paper = Paper.new(:user => user, :state => :submitted)
    ability = Ability.new(user, owned_paper)
    assert ability.cannot?(:update, owned_paper)
  end

  # DELETE (as author)

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
end
