class Subscription < ApplicationRecord
  belongs_to :user
  validates :paypal_subscription_id, presence: true, uniqueness: true
  validates :plan_id, :status, presence: true
end
