class WebhooksController < ApplicationController
  skip_forgery_protection only: :receive
  rescue_with Stripe::SignatureVerificationError, status: 400

  def receive
    if params[:source] == "stripe"
      UserUpgrade.receive_webhook(request)
      head 200
    else
      head 400
    end
  end
end
