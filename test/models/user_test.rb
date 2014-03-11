require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "user can only destroy projects which he owns" do
    user = User.create!
    owned_paper = Paper.new(:user => user) 
    ability = Ability.new(user, owned_paper)
    assert ability.can?(:destroy, owned_paper)
  end
end
