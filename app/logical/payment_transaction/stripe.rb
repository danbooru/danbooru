# frozen_string_literal: true

class PaymentTransaction::Stripe < PaymentTransaction
  delegate :transaction_id, to: :user_upgrade

  def self.enabled?
    Danbooru.config.stripe_secret_key.present? && Danbooru.config.stripe_publishable_key.present? && Danbooru.config.stripe_webhook_secret.present?
  end

  def create!(country: "US", allow_promotion_codes: false)
    checkout_session = ::Stripe::Checkout::Session.create(
      mode: "payment",
      success_url: Routes.user_upgrade_url(user_upgrade),
      cancel_url: Routes.new_user_upgrade_url(user_id: recipient.id),
      client_reference_id: "user_upgrade_#{user_upgrade.id}",
      customer_email: purchaser.email_address&.address,
      payment_method_types: payment_method_types(country),
      allow_promotion_codes: allow_promotion_codes.presence,
      line_items: [{
        price: upgrade_price_id(country),
        quantity: 1,
      }],
      discounts: [{
        coupon: promotion_discount_id,
      }],
      metadata: {
        user_upgrade_id: user_upgrade.id,
        purchaser_id: purchaser.id,
        recipient_id: recipient.id,
        purchaser_name: purchaser.name,
        recipient_name: recipient.name,
        upgrade_type: upgrade_type,
        country: country,
        is_gift: user_upgrade.is_gift?,
        level: user_upgrade.level,
      }
    )

    user_upgrade.update!(payment_processor: :stripe, transaction_id: checkout_session.id)
    checkout_session
  end

  def refund!(reason = nil)
    ::Stripe::Refund.create(payment_intent: payment_intent.id, reason: reason)
  end

  concerning :WebhookMethods do
    class_methods do
      def receive_webhook(request)
        event = build_event(request)

        case event.type
        when "checkout.session.completed"
          checkout_session_completed(event.data.object)
        when "charge.dispute.created"
          charge_dispute_created(event.data.object)
        when "radar.early_fraud_warning.created"
          radar_early_fraud_warning_created(event.data.object)
        end
      end

      private def build_event(request)
        payload = request.body.read
        signature = request.headers["Stripe-Signature"]
        ::Stripe::Webhook.construct_event(payload, signature, Danbooru.config.stripe_webhook_secret)
      end

      private def checkout_session_completed(checkout)
        user_upgrade = UserUpgrade.find(checkout.metadata.user_upgrade_id)
        user_upgrade.process_upgrade!(checkout.payment_status)
      end

      private def charge_dispute_created(dispute)
        Dmail.create_automated(to: User.owner, title: "Stripe Dispute", body: <<~EOS)
          Dispute: https://stripe.com/payments/#{dispute.charge}
        EOS
      end

      private def radar_early_fraud_warning_created(fraud_warning)
        Dmail.create_automated(to: User.owner, title: "Stripe Early Fraud Warning", body: <<~EOS)
          Charge: https://stripe.com/payments/#{fraud_warning.charge}
        EOS
      end

      private def register_webhook
        webhook = ::Stripe::WebhookEndpoint.create({
          url: Routes.webhook_user_upgrade_url(source: "stripe"),
          enabled_events: [
            "checkout.session.completed",
            "checkout.session.async_payment_failed",
            "checkout.session.async_payment_succeeded",
            "charge.dispute.created",
            "radar.early_fraud_warning.created",
          ],
        })

        webhook.secret
      end
    end
  end

  def receipt_url
    return nil if pending? || transaction_id.nil?
    charge.receipt_url
  end

  def payment_url
    return nil if pending? || transaction_id.nil?
    "https://dashboard.stripe.com/payments/#{payment_intent.id}"
  end

  def amount
    payment_intent.amount
  end

  def currency
    payment_intent.currency
  end

  private def checkout_session
    return nil if transaction_id.nil?
    @checkout_session ||= ::Stripe::Checkout::Session.retrieve(transaction_id)
  end

  private def payment_intent
    return nil if checkout_session.nil?
    @payment_intent ||= ::Stripe::PaymentIntent.retrieve(checkout_session.payment_intent)
  end

  private def charge
    payment_intent.charges.data.first
  end

  private def payment_method_types(country)
    case country.to_s.upcase
    # Austria, https://stripe.com/docs/payments/bancontact
    when "AT"
      ["card", "eps"]
    # Belgium, https://stripe.com/docs/payments/eps
    when "BE"
      ["card", "bancontact"]
    # Germany, https://stripe.com/docs/payments/giropay
    when "DE"
      ["card", "giropay"]
    # Netherlands, https://stripe.com/docs/payments/ideal
    when "NL"
      ["card", "ideal"]
    # Poland, https://stripe.com/docs/payments/p24
    when "PL"
      ["card", "p24"]
    else
      ["card"]
    end
  end

  private def preferred_currency(country)
    case country.to_s.upcase
    # Austria, Belgium, Germany, Netherlands, Poland
    when "AT", "BE", "DE", "NL", "PL"
      "eur"
    else
      "usd"
    end
  end

  private def upgrade_price_id(country)
    case [upgrade_type, preferred_currency(country)]
    when ["gold", "usd"]
      Danbooru.config.stripe_gold_usd_price_id
    when ["gold", "eur"]
      Danbooru.config.stripe_gold_eur_price_id
    when ["platinum", "usd"]
      Danbooru.config.stripe_platinum_usd_price_id
    when ["platinum", "eur"]
      Danbooru.config.stripe_platinum_eur_price_id
    when ["gold_to_platinum", "usd"]
      Danbooru.config.stripe_gold_to_platinum_usd_price_id
    when ["gold_to_platinum", "eur"]
      Danbooru.config.stripe_gold_to_platinum_eur_price_id
    else
      raise NotImplementedError
    end
  end

  private def promotion_discount_id
    if Danbooru.config.is_promotion?
      Danbooru.config.stripe_promotion_discount_id
    end
  end
end
