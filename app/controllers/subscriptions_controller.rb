# app/controllers/subscriptions_controller.rb
require "net/http"
require "json"
require "securerandom"

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :cancel_paypal]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  PAYPAL_API = "https://api-m.sandbox.paypal.com"

  # GET /subscriptions/new
  def new
    # renders app/views/subscriptions/new.html.erb (see step 6)
  end

  # POST /subscriptions
  # Creates a PayPal subscription and returns the approval link
  def create
  access_token = generate_access_token

  url = URI("https://api-m.sandbox.paypal.com/v1/billing/subscriptions")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true

  request = Net::HTTP::Post.new(url)
  request["Authorization"] = "Bearer #{access_token}"
  request["Content-Type"] = "application/json"

  request.body = {
    plan_id:  ENV['PAYPAL_PLAN_ID'],
    application_context: {
      brand_name: "My Shop",
      return_url: success_subscriptions_url,
      cancel_url: cancel_subscriptions_url
    }
  }.to_json

  response = http.request(request)
  body = JSON.parse(response.body)

  if response.code == "201" && body["links"]
    approval_url = body["links"].find { |l| l["rel"] == "approve" }["href"]

    Subscription.create!(
      user: current_user,
      paypal_subscription_id: body["id"],
      plan_id: "P-12345678",
      status: body["status"] || "PENDING"
    )

    render json: { approval_url: approval_url }
  else
    render json: { error: "Failed to create subscription", details: body }, status: :unprocessable_entity
  end
end

  # GET /subscriptions/success?subscription_id=...
  # PayPal redirects here after user approves
  def success
    subscription_id = params[:subscription_id] || params[:token]
    if subscription_id.blank?
      redirect_to root_path, alert: "Missing subscription id"
      return
    end

    # fetch subscription details
    token = generate_access_token
    uri = URI("#{PAYPAL_API}/v1/billing/subscriptions/#{subscription_id}")
    req = Net::HTTP::Get.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{token}"

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    data = parse_response(res)

    if res.code.to_i == 200 && data["id"]
      if current_user
        Subscription.create_with(
          plan_id: data["plan_id"],
          status: data["status"],
          start_time: data["start_time"]
        ).find_or_create_by!(user: current_user, paypal_subscription_id: data["id"])
        redirect_to root_path, notice: "Subscription #{data['status']}"
      else
        # session may have expired; rely on webhook if necessary
        redirect_to new_user_session_path, notice: "Please sign in to link your subscription"
      end
    else
      redirect_to root_path, alert: "Could not verify subscription"
    end
  rescue => e
    Rails.logger.error("[Subscriptions#success] #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Internal error"
  end

  # GET /subscriptions/cancel
  def cancel
    redirect_to root_path, alert: "Subscription process cancelled."
  end

  # POST /subscriptions/webhook
  # PayPal will send events here (ACTIVATED, CANCELLED, PAYMENT.SALE.COMPLETED)
  def webhook
    raw = request.body.read
    event = JSON.parse(raw) rescue nil
    Rails.logger.info "[PayPal Webhook] event_type=#{event&.dig('event_type')}, resource_id=#{event&.dig('resource','id')}"

    # In production you should verify signature (see helper below)
    # verify_webhook_signature(raw) -> returns true/false

    if event
      case event["event_type"]
      when "BILLING.SUBSCRIPTION.ACTIVATED", "BILLING.SUBSCRIPTION.CREATED"
        sid = event.dig("resource", "id")
        Subscription.find_by(paypal_subscription_id: sid)&.update(status: "ACTIVE")
      when "BILLING.SUBSCRIPTION.CANCELLED"
        sid = event.dig("resource", "id")
        Subscription.find_by(paypal_subscription_id: sid)&.update(status: "CANCELLED")
      when "PAYMENT.SALE.COMPLETED", "PAYMENT.CAPTURE.COMPLETED"
        # recurring payment succeeded -> create Payment/Invoice if you want
      end
    end

    head :ok
  rescue => e
    Rails.logger.error("[Subscriptions#webhook] #{e.class}: #{e.message}")
    head :internal_server_error
  end

  # POST /subscriptions/:id/cancel_paypal
  def cancel_paypal
    sub = current_user.subscriptions.find(params[:id])
    token = generate_access_token
    uri = URI("#{PAYPAL_API}/v1/billing/subscriptions/#{sub.paypal_subscription_id}/cancel")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{token}"
    req.body = { reason: "Cancelled by user" }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    if [200, 204].include?(res.code.to_i)
      sub.update(status: "CANCELLED")
      redirect_to root_path, notice: "Subscription cancelled"
    else
      Rails.logger.error("[Subscriptions#cancel_paypal] #{res.code} #{res.body}")
      redirect_to root_path, alert: "Could not cancel subscription"
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Subscription not found"
  end

  private

  def parse_response(res)
    JSON.parse(res.body) rescue res.body
  end

  def generate_access_token
    uri = URI("#{PAYPAL_API}/v1/oauth2/token")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth ENV["PAYPAL_CLIENT_ID"], ENV["PAYPAL_CLIENT_SECRET"]
    req.set_form_data("grant_type" => "client_credentials")

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    body = JSON.parse(res.body) rescue {}
    body["access_token"]
  end

  # OPTIONAL (production) helper to verify webhook signature
  def verify_webhook_signature(raw_body)
    transmission_id     = request.headers["Paypal-Transmission-Id"]
    transmission_time   = request.headers["Paypal-Transmission-Time"]
    cert_url            = request.headers["Paypal-Cert-Url"]
    auth_algo           = request.headers["Paypal-Auth-Algo"]
    transmission_sig    = request.headers["Paypal-Transmission-Sig"]
    webhook_id          = ENV["PAYPAL_WEBHOOK_ID"]

    return false if transmission_id.blank? || webhook_id.blank?

    uri = URI("#{PAYPAL_API}/v1/notifications/verify-webhook-signature")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = {
      transmission_id: transmission_id,
      transmission_time: transmission_time,
      cert_url: cert_url,
      auth_algo: auth_algo,
      transmission_sig: transmission_sig,
      webhook_id: webhook_id,
      webhook_event: JSON.parse(raw_body) # full event json
    }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    data = parse_response(res)
    data["verification_status"] == "SUCCESS"
  end
end


