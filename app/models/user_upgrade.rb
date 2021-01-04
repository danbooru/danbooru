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
    complete: 20,
    refunded: 30,
  }

  scope :gifted, -> { where("recipient_id != purchaser_id") }
  scope :self_upgrade, -> { where("recipient_id = purchaser_id") }

  def self.enabled?
    stripe_secret_key.present? && stripe_publishable_key.present? && stripe_webhook_secret.present?
  end

  def self.stripe_secret_key
    Danbooru.config.stripe_secret_key
  end

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

  def previous_level
    case upgrade_type
    when "gold"
      User::Levels::MEMBER
    when "platinum"
      User::Levels::MEMBER
    when "gold_to_platinum"
      User::Levels::GOLD
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

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(recipient: user).or(where(purchaser: user))
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :upgrade_type, :status, :stripe_id, :recipient, :purchaser)

    if params[:is_gifted].to_s.truthy?
      q = q.gifted
    elsif params[:is_gifted].to_s.falsy?
      q = q.self_upgrade
    end

    q = q.apply_default_order(params)
    q
  end

  concerning :UpgradeMethods do
    def process_upgrade!(payment_status)
      recipient.with_lock do
        return unless pending? || processing?

        if payment_status == "paid"
          upgrade_recipient!
          create_mod_action!
          dmail_recipient!
          dmail_purchaser!
          update!(status: :complete)
        else
          update!(status: :processing)
        end
      end
    end

    def upgrade_recipient!
      recipient.update!(level: level, inviter: User.system)
    end

    def create_mod_action!
      ModAction.log(%{"#{recipient.name}":#{Routes.user_path(recipient)} level changed #{User.level_string(recipient.level_before_last_save)} -> #{recipient.level_string}}, :user_account_upgrade, purchaser)
    end

    def dmail_recipient!
      if is_gift?
        body = "Congratulations, your account has been upgraded to #{level_string} by <@#{purchaser.name}>. Enjoy!"
      else
        body = "You are now a #{level_string} user. Thanks for supporting #{Danbooru.config.canonical_app_name}!"
      end

      title = "You have been upgraded to #{level_string}!"
      Dmail.create_automated(to: recipient, title: title, body: body)
    end

    def dmail_purchaser!
      return unless is_gift?

      title = "#{recipient.name} has been upgraded to #{level_string}!"
      body = "<@#{recipient.name}> is now a #{level_string} user. Thanks for supporting #{Danbooru.config.canonical_app_name}!"

      Dmail.create_automated(to: purchaser, title: title, body: body)
    end
  end

  concerning :StripeMethods do
    def create_checkout!(country: "US", allow_promotion_codes: false)
      methods = payment_method_types(country)
      currency = preferred_currency(country)
      price_id = upgrade_price_id(currency)

      checkout = Stripe::Checkout::Session.create(
        mode: "payment",
        success_url: Routes.user_upgrade_url(self),
        cancel_url: Routes.new_user_upgrade_url(user_id: recipient.id),
        client_reference_id: "user_upgrade_#{id}",
        customer_email: purchaser.email_address&.address,
        payment_method_types: methods,
        allow_promotion_codes: allow_promotion_codes,
        line_items: [{
          price: price_id,
          quantity: 1,
        }],
        metadata: {
          user_upgrade_id: id,
          purchaser_id: purchaser.id,
          recipient_id: recipient.id,
          purchaser_name: purchaser.name,
          recipient_name: recipient.name,
          upgrade_type: upgrade_type,
          country: country,
          is_gift: is_gift?,
          level: level,
        },
      )

      update!(stripe_id: checkout.id)
      checkout
    end

    def refund!(reason: nil)
      with_lock do
        return if refunded?

        Stripe::Refund.create(payment_intent: payment_intent.id, reason: reason)
        recipient.update!(level: previous_level)
        update!(status: "refunded")
      end
    end

    def receipt_url
      return nil if pending? || stripe_id.nil?
      charge.receipt_url
    end

    def payment_url
      return nil if pending? || stripe_id.nil?
      "https://dashboard.stripe.com/payments/#{payment_intent.id}"
    end

    def checkout_session
      @checkout_session ||= Stripe::Checkout::Session.retrieve(stripe_id)
    end

    def payment_intent
      @payment_intent ||= Stripe::PaymentIntent.retrieve(checkout_session.payment_intent)
    end

    def charge
      payment_intent.charges.data.first
    end

    def has_receipt?
      !pending?
    end

    def has_payment?
      !pending?
    end

    def upgrade_price_id(currency)
      case [upgrade_type, currency]
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

    def payment_method_types(country)
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

    def preferred_currency(country)
      case country.to_s.upcase
      # Austria, Belgium, Germany, Netherlands, Poland
      when "AT", "BE", "DE", "NL", "PL"
        "eur"
      else
        "usd"
      end
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
