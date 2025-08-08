class Product < ApplicationRecord
  belongs_to :seller, class_name: "User"
  has_many :purchases, dependent: :destroy
  has_many :buyers, through: :purchases, class_name: "User"

  has_many :reviews, dependent: :destroy
  has_many :cart_items
  has_many :carts, through: :cart_items

  has_many_attached :images
  has_rich_text :description
end
