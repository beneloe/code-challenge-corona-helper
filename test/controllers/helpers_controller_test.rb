require 'test_helper'

class HelpersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get helpers_create_url
    assert_response :success
  end

end
