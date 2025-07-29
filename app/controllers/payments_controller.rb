class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:paypal]

  def checkout
    # Optional: Load cart/order info here
  end

  def paypal
    # Save transaction info if needed
    transaction = params.as_json

    # Example: create Payment record (if you have one)
    # Payment.create!(
    #   payer_email: transaction.dig("payer", "email_address"),
    #   transaction_id: transaction["id"],
    #   amount: transaction.dig("purchase_units", 0, "amount", "value"),
    #   status: transaction["status"]
    # )

    render json: { status: "success" }
  end

  def thank_you
  end
end
