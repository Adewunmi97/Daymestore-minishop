class Order < ApplicationRecord
  belongs_to :user

  has_many :purchases
  has_many :products, through: :purchases

  enum :status, {
    pending: 0,
    processing: 1,
    fulfilled: 2,
    cancelled: 3,
    refunded: 4
  }

  before_update :set_status_changed_at, if: :will_save_change_to_status?

  private

  def set_status_changed_at
    self.status_changed_at = Time.current
  end
end
