class UserUpgrade
  attr_reader :recipient, :purchaser, :level

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

  def initialize(recipient:, purchaser:, level:)
    @recipient, @purchaser, @level = recipient, purchaser, level.to_i
  end

  def upgrade_type
    if level == User::Levels::GOLD && recipient.level == User::Levels::MEMBER
      :gold_upgrade
    elsif level == User::Levels::PLATINUM && recipient.level == User::Levels::MEMBER
      :platinum_upgrade
    elsif level == User::Levels::PLATINUM && recipient.level == User::Levels::GOLD
      :gold_to_platinum_upgrade
    else
      raise ArgumentError, "Invalid upgrade"
    end
  end

  def upgrade_price
    case upgrade_type
    when :gold_upgrade
      UserUpgrade.gold_price
    when :platinum_upgrade
      UserUpgrade.platinum_price
    when :gold_to_platinum_upgrade
      UserUpgrade.gold_to_platinum_price
    end
  end

  def upgrade_description
    case upgrade_type
    when :gold_upgrade
      "Upgrade to Gold"
    when :platinum_upgrade
      "Upgrade to Platinum"
    when :gold_to_platinum_upgrade
      "Upgrade Gold to Platinum"
    end
  end

  def is_gift?
    recipient != purchaser
  end

  def process_upgrade!
    recipient.with_lock do
      upgrade_recipient!
    end
  end

  def upgrade_recipient!
    recipient.promote_to!(level, User.system, is_upgrade: true)
  end

  concerning :StripeMethods do
    def create_checkout
      Stripe::Checkout::Session.create(
        mode: "payment",
        success_url: Routes.user_upgrade_url(user_id: recipient.id),
        cancel_url: Routes.new_user_upgrade_url(user_id: recipient.id),
        client_reference_id: "user_#{purchaser.id}",
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
          purchaser_id: purchaser.id,
          recipient_id: recipient.id,
          purchaser_name: purchaser.name,
          recipient_name: recipient.name,
          upgrade_type: upgrade_type,
          is_gift: is_gift?,
          level: level,
        },
      )
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
          checkout_session_completed(event)
        end
      end

      def build_event(request)
        payload = request.body.read
        signature = request.headers["Stripe-Signature"]
        Stripe::Webhook.construct_event(payload, signature, stripe_webhook_secret)
      end

      def checkout_session_completed(event)
        recipient = User.find(event.data.object.metadata.recipient_id)
        purchaser = User.find(event.data.object.metadata.purchaser_id)
        level = event.data.object.metadata.level

        user_upgrade = UserUpgrade.new(recipient: recipient, purchaser: purchaser, level: level)
        user_upgrade.process_upgrade!
      end
    end
  end
end
