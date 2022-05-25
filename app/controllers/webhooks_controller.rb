# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_forgery_protection only: [:receive, :authorize_net]

  rescue_with Stripe::SignatureVerificationError, status: 400
  rescue_with DiscordSlashCommand::WebhookVerificationError, status: 401

  def receive
    case params[:source]
    when "stripe"
      PaymentTransaction::Stripe.receive_webhook(request)
      head 200
    when "shopify"
      PaymentTransaction::Shopify.receive_webhook(request)
      head 200
    when "discord"
      json = DiscordSlashCommand.receive_webhook(request)
      render json: json
    else
      head 400
    end
  end

  def authorize_net
    PaymentTransaction::AuthorizeNet.receive_webhook(request)
    head 200
  end
end
