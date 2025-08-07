class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  broadcasts_refreshes_to :product
end
