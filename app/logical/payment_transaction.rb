# frozen_string_literal: true

# A PaymentTransaction represents a payment in some payment processor's backend API.
#
# @see app/logical/payment_transaction/stripe.rb
class PaymentTransaction
  attr_reader :user_upgrade
  delegate :recipient, :purchaser, :upgrade_type, :pending?, :transaction_id, to: :user_upgrade

  def initialize(user_upgrade)
    @user_upgrade = user_upgrade
  end

  # Initiate a new payment. Normally this sets up a checkout page with the payment processor, which
  # we redirect the user to. When the payment succeeds, the user is redirected to a success page and
  # the processor sends us a webhook, which we catch to finalize the upgrade. If the payment fails,
  # the user is redirected to an error page and the upgrade doesn't go through.
  #
  # Normally this returns a processor-specific transaction object containing an ID or URL, which is
  # used to redirect to the checkout page.
  def create!(country: "US", allow_promotion_codes: false)
    raise NotImplementedError
  end

  # Refund a completed payment to the purchaser.
  def refund!
    raise NotImplementedError
  end

  # Handle a webhook from the payment processor. Normally the payment processor sends us a webhook
  # to notify us of successful payments, which we listen for to complete the upgrade.
  def receive_webhook!(request)
    raise NotImplementedError
  end

  # A public link to the payment processor's receipt for the transaction.
  def receipt_url
    nil
  end

  # A private link to the transaction in the payment processor's admin area.
  def payment_url
    nil
  end

  # The amount of money paid in the transaction.
  def amount
    nil
  end

  # The currency used in the transaction.
  def currency
    nil
  end
end
