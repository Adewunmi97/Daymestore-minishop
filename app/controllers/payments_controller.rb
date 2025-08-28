require "net/http"
require "json"

class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create_order, :capture_order]

  PAYPAL_API = "https://api-m.sandbox.paypal.com"

  def create_order
    cart = current_user.cart
    if cart.nil? || cart.cart_items.empty?
      return render json: { error: "Cart is empty" }, status: :unprocessable_entity
    end

    items = cart.cart_items.includes(:product)

    # Build PayPal line items
    paypal_items = items.map do |item|
      price = item.product&.price || 0
      qty   = item.quantity || 1

      {
        name: item.product&.title || "Unknown Product",
        unit_amount: {
          currency_code: "USD",
          value: price.to_s
        },
        quantity: qty.to_s
      }
    end

    # Safely calculate total
    total = items.sum do |item|
      (item.product&.price || 0) * (item.quantity || 1)
    end

    order = {
      intent: "CAPTURE",
      purchase_units: [{
        amount: {
          currency_code: "USD",
          value: total.to_s,
          breakdown: {
            item_total: {
              currency_code: "USD",
              value: total.to_s
            }
          }
        },
        items: paypal_items
      }],
      application_context: {
        return_url: payments_thank_you_url,
        cancel_url: cart_url
      }
    }

    uri = URI("#{PAYPAL_API}/v2/checkout/orders")
    req = Net::HTTP::Post.new(uri, headers)
    req.body = order.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    render json: JSON.parse(res.body)
  end

  def capture_order
  order_id = params[:order_id]
  uri = URI("#{PAYPAL_API}/v2/checkout/orders/#{order_id}/capture")
  req = Net::HTTP::Post.new(uri, headers)

  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  transaction = JSON.parse(res.body)

  if transaction["status"] == "COMPLETED"
    # Map PayPal status → Rails enum
    mapped_status = case transaction["status"]
                    when "COMPLETED" then :fulfilled
                    when "PENDING"   then :pending
                    when "CANCELLED" then :cancelled
                    else :processing
                    end

    order = current_user.orders.create!(
      total_amount: current_user.cart.total_amount,
      status: mapped_status,
      payment_id: transaction["id"],   # ✅ fix: use real column
      payment_method: "paypal"
    )

    # Send confirmation email
    SendOrderConfirmationJob.perform_later(order.id)

    # Clear the cart
    current_user.cart.cart_items.destroy_all

    # Redirect to scaffolded order page
    redirect_to order_path(order), notice: "Payment successful! 🎉"
  else
    render json: { error: "Payment not approved", details: transaction }, status: :unprocessable_entity
  end
end


  def thank_you; end

  private

  def headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{generate_access_token}"
    }
  end

  def generate_access_token
    uri = URI("#{PAYPAL_API}/v1/oauth2/token")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth ENV["PAYPAL_CLIENT_ID"], ENV["PAYPAL_CLIENT_SECRET"]
    req.set_form_data("grant_type" => "client_credentials")

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    JSON.parse(res.body)["access_token"]
  end
end
