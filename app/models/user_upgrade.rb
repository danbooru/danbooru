class UserUpgrade < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :purchaser, class_name: "User"

  enum upgrade_type: {
    gold: 0,
    platinum: 10,
    gold_to_platinum: 20
  }, _suffix: "upgrade"

  enum status: {
    pending: 0,
    processing: 10,
    complete: 20
  }

  def self.stripe_publishable_key
    Danbooru.config.stripe_publishable_key
  end

  def self.stripe_webhook_secret
    Danbooru.config.stripe_webhook_secret
  end

  def self.gold_price
    2000
  end

  def self.platinum_price
    2 * gold_price
  end

  def self.gold_to_platinum_price
    platinum_price - gold_price
  end

  def level
    case upgrade_type
    when "gold"
      User::Levels::GOLD
    when "platinum"
      User::Levels::PLATINUM
    when "gold_to_platinum"
      User::Levels::PLATINUM
    else
      raise NotImplementedError
    end
  end

  def upgrade_price
    case upgrade_type
    when "gold"
      UserUpgrade.gold_price
    when "platinum"
      UserUpgrade.platinum_price
    when "gold_to_platinum"
      UserUpgrade.gold_to_platinum_price
    else
      raise NotImplementedError
    end
  end

  def upgrade_description
    case upgrade_type
    when "gold"
      "Upgrade to Gold"
    when "platinum"
      "Upgrade to Platinum"
    when "gold_to_platinum"
      "Upgrade Gold to Platinum"
    else
      raise NotImplementedError
    end
  end

  def level_string
    User.level_string(level)
  end

  def is_gift?
    recipient != purchaser
  end

  def process_upgrade!(payment_status)
    recipient.with_lock do
      return if status == "complete"

      if payment_status == "paid"
        upgrade_recipient!
        update!(status: :complete)
      else
        update!(status: :processing)
      end
    end
  end

  def upgrade_recipient!
    recipient.promote_to!(level, User.system, is_upgrade: true)
  end

  concerning :StripeMethods do
    def create_checkout!
      checkout = Stripe::Checkout::Session.create(
        mode: "payment",
        success_url: Routes.user_upgrade_url(self),
        cancel_url: Routes.new_user_upgrade_url(user_id: recipient.id),
        client_reference_id: "user_upgrade_#{id}",
        customer_email: recipient.email_address&.address,
        payment_method_types: ["card"],
        line_items: [{
          price_data: {
            unit_amount: upgrade_price,
            currency: "usd",
            product_data: {
              name: upgrade_description,
            },
          },
          quantity: 1,
        }],
        metadata: {
          user_upgrade_id: id,
          purchaser_id: purchaser.id,
          recipient_id: recipient.id,
          purchaser_name: purchaser.name,
          recipient_name: recipient.name,
          upgrade_type: upgrade_type,
          is_gift: is_gift?,
          level: level,
        },
      )

      update!(stripe_id: checkout.id)
      checkout
    end

    class_methods do
      def register_webhook
        webhook = Stripe::WebhookEndpoint.create({
          url: Routes.webhook_user_upgrade_url(source: "stripe"),
          enabled_events: [
            "payment_intent.created",
            "payment_intent.payment_failed",
            "checkout.session.completed",
          ],
        })

        webhook.secret
      end

      def receive_webhook(request)
        event = build_event(request)

        if event.type == "checkout.session.completed"
          checkout_session_completed(event.data.object)
        end
      end

      def build_event(request)
        payload = request.body.read
        signature = request.headers["Stripe-Signature"]
        Stripe::Webhook.construct_event(payload, signature, stripe_webhook_secret)
      end

      def checkout_session_completed(checkout)
        user_upgrade = UserUpgrade.find(checkout.metadata.user_upgrade_id)
        user_upgrade.process_upgrade!(checkout.payment_status)
      end
    end
  end
end
