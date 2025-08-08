class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :profile_photo

  #seller
  has_many :products, foreign_key: :seller_id, dependent: :destroy
  
  #buyer
  has_many :purchases, foreign_key: :buyer_id, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart
  has_many :orders

  def has_purchased?(product)
    purchases.where(product_id: product.id).any?
  end
end
