class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validate :user_cannot_add_own_product

  private

  def user_cannot_add_own_product
    if cart.user_id == product.seller_id
      errors.add(:base, "You cannot add your own product to the cart.")
    end
  end
end
