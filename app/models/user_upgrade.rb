# frozen_string_literal: true

class UserUpgrade < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :purchaser, class_name: "User"

  delegate :payment_url, :receipt_url, to: :transaction

  enum upgrade_type: {
    gold: 0,
    platinum: 10,
    gold_to_platinum: 20,
  }, _suffix: "upgrade"

  enum status: {
    pending: 0,
    processing: 10,
    complete: 20,
    refunded: 30,
  }

  enum payment_processor: {
    stripe: 0,
    authorize_net: 100,
  }

  scope :gifted, -> { where("recipient_id != purchaser_id") }
  scope :self_upgrade, -> { where("recipient_id = purchaser_id") }

  def self.enabled?
    Danbooru.config.user_upgrades_enabled?.to_s.truthy?
  end

  def self.gold_price
    if Danbooru.config.is_promotion?
      15.00
    else
      20.00
    end
  end

  def self.platinum_price
    2 * gold_price
  end

  def self.gold_to_platinum_price
    platinum_price - gold_price
  end

  def price
    case upgrade_type
    in "gold"
      UserUpgrade.gold_price
    in "platinum"
      UserUpgrade.platinum_price
    in "gold_to_platinum"
      UserUpgrade.gold_to_platinum_price
    end
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
    q = search_attributes(params, :id, :created_at, :updated_at, :upgrade_type, :status, :transaction_id, :payment_processor, :recipient, :purchaser)

    if params[:is_gifted].to_s.truthy?
      q = q.gifted
    elsif params[:is_gifted].to_s.falsy?
      q = q.self_upgrade
    end

    q.apply_default_order(params)
  end

  concerning :UpgradeMethods do
    def process_upgrade!(payment_status)
      recipient.with_lock do
        return unless pending? || processing?

        if payment_status == "paid"
          upgrade_recipient!
          dmail_recipient!
          dmail_purchaser!
          update!(status: :complete)
        else
          update!(status: :processing)
        end
      end
    end

    def upgrade_recipient!
      recipient.update!(level: level)
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

  concerning :TransactionMethods do
    def create_checkout!(country: "US", allow_promotion_codes: false)
      transaction.create!(country: country, allow_promotion_codes: allow_promotion_codes)
    end

    def refund!(reason: nil)
      with_lock do
        return if refunded?

        transaction.refund!(reason)
        recipient.update!(level: previous_level)
        update!(status: "refunded")
      end
    end

    def transaction
      case payment_processor
      in "stripe"
        PaymentTransaction::Stripe.new(self)
      in "authorize_net"
        PaymentTransaction::AuthorizeNet.new(self)
      end
    end

    def has_receipt?
      !pending?
    end

    def has_payment?
      !pending?
    end
  end
end
