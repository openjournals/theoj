require 'test_helper'

class PapersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, :format => :json
    assert_response :success
  end
end
