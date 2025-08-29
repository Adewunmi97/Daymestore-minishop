class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items
  has_many :products, through: :cart_items

  def total_amount
    products.sum(:price)
  end

  def add(product)
    cart_items.find_or_create_by(product: product)
  end

  def remove(product)
    if cart_item = cart_items.find_by(product: product)
      cart_item.destroy
    end
  end

  def empty!
    cart_items.destroy_all
  end

  def is_empty?
    cart_items.empty!
  end
end
