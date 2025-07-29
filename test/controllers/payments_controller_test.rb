require "test_helper"

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  test "should get paypal" do
    get payments_paypal_url
    assert_response :success
  end

  test "should get checkout" do
    get payments_checkout_url
    assert_response :success
  end
end
