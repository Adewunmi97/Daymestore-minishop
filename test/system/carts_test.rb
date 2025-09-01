require "application_system_test_case"

class CartsTest < ApplicationSystemTestCase
  setup do
    @buyer = users(:two)
    @product = products(:one)
    @product2 = products(:two)
    sign_in @buyer
    @buyer.cart.empty!
  end

  test "adding new product to cart" do 
    visit product_url(@product)
    click_on "Add to cart"
    assert_selector "turbo-frame#cartsize div", text: "1"
    assert_selector "button#add_to_cart_button", text: "Added to cart"
  end

  test "removing product from the cart" do
    visit product_url(@product)
    click_on "Add to cart"
    visit product_url(@product2)
    click_on "Add to cart"
    visit cart_url

    assert_text @product.title
    first("button.remove-item").click
    assert_no_text @product.title
    assert_selector "turbo-frame#cartsize div", text: "1"
  end

  test "displaying correct cart items and total amount on page" do
    visit product_url(@product)
    click_on "Add to cart"
    visit product_url(@product2)
    click_on "Add to cart"
    visit cart_url

    assert_text @product.title
    assert_text "$#{@product.price}"
    assert_text @product2.title
    assert_text "$#{@product2.price}"

    assert_text "$#{@buyer.cart.total_amount}"
  end
end
