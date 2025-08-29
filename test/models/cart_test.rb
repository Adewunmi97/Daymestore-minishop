require "test_helper"

class CartTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @cart = @user.cart
    @cart.empty!
    @product1 = products(:one)
    @product2 = products(:two)
  end

  test "calculates total amount" do
    @cart.cart_items.create!(product: @product1)
    @cart.cart_items.create!(product: @product2)

    assert_equal 29.00, @cart.total_amount
  end

  test "adds product to cart" do
    @cart.add(@product1)
    assert_includes @cart.cart_items, CartItem.find_by(product: @product1)
  end

  test "does not add product to cart if it already exist" do
    @cart.add(@product1)
    @cart.add(@product1)
    assert_equal 1, @cart.cart_items.size
  end

  test "removes product from cart" do
    @cart.add(@product1)
    @cart.remove(@product1)
    assert_not_includes @cart.cart_items, CartItem.find_by(product: @product1)
  end

  test "cart empties" do
    @cart.add(@product1)
    @cart.add(@product1)
    @cart.empty!
    assert_equal 0, @cart.cart_items.size
  end
end
