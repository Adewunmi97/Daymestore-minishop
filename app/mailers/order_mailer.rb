class OrderMailer < ApplicationMailer
  def confirmation
    @order = Order.find(params[:order_id])
    @customer = @order.user
    mailer(
      to: @customer.email,
      subject: "Your order confirmation ##{@order.id}"
    )
  end
end
