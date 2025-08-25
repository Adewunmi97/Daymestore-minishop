# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  def confirmation
    order = Order.last
    OrderMailer.with(order_id: order.id).confirmation
  end
end
