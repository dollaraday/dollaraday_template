require_relative '../test_helper'

class NonprofitsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :redirect, "should redirect"
  end
end
