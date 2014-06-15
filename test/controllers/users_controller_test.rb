require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get show" do
    user = User.create!
    get :show, :id => user.sha, :format => :json
    assert_response :success
  end
end
