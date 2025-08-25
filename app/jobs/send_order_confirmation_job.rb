class SendOrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    sleep 10
    OrderMailer.with(order_id: order_id).confirmation.deliver_now
  end
end
