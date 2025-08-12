class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items
  has_many :products, through: :cart_items

  def total_amount
    products.sum(:price)
  end
end
