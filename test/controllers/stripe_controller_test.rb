require 'test_helper'

class StripeControllerTest < ActionDispatch::IntegrationTest
  test "should get create_checkout_session" do
    get stripe_create_checkout_session_url
    assert_response :success
  end

end
