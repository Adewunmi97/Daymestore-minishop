require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "should check if user has purchased a product" do
    product = products(:one)
    order = @user.orders.create!(
      status: :fulfilled,
      total_amount: 10
    )
    order.purchases.create!(
      product: product,
      buyer: @user
    )

    assert @user.has_purchased?(product)
  end
end
