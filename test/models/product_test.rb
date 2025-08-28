require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @product = products(:one)
  end

  test "title should be present" do
    @product.title = ""
    assert_not @product.valid?
    assert_includes @product.errors[:title], "can't be blank"
  end

  test "price should be present" do
    @product.price = nil
    assert_not @product.valid?
  end

  test "price should be positive" do
    @product.price = 0
    assert_not @product.valid?
    @product.price = -1
    assert_not @product.valid?
  end
end
