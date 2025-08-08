class Purchase < ApplicationRecord
  belongs_to :product
  belongs_to :buyer, class_name: "User"
  belongs_to :order, optional: true
end
