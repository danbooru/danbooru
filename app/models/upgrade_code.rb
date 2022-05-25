# frozen_string_literal: true

# A code that can be redeemed for a Gold account. Codes are pre-generated and
# one time use only. Upgrade codes are sold in the Danbooru store.
class UpgradeCode < ApplicationRecord
  class InvalidCodeError < StandardError; end
  class RedeemedCodeError < StandardError; end
  class AlreadyUpgradedError < StandardError; end

  UPGRADE_CODE_LENGTH = 8

  attribute :code, default: -> { UpgradeCode.generate_code }
  attribute :status, default: :unsold

  belongs_to :creator, class_name: "User"
  belongs_to :redeemer, class_name: "User", optional: true
  belongs_to :user_upgrade, optional: true

  enum status: {
    unsold: 0,
    unredeemed: 100,
    redeemed: 200,
  }

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(redeemer: user).or(where(creator: user))
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :code, :status, :creator, :redeemer, :user_upgrade)
    q.apply_default_order(params)
  end

  def self.generate_code
    SecureRandom.send(:choose, [*"0".."9", *"A".."Z", *"a".."z"], UPGRADE_CODE_LENGTH) # base62
  end

  def self.redeem!(code:, redeemer:)
    upgrade_code = UpgradeCode.find_by(code: code)
    raise InvalidCodeError, "This upgrade code is invalid" if upgrade_code.nil?

    upgrade_code.redeem!(redeemer)
  end

  def redeem!(redeemer)
    transaction do
      raise RedeemedCodeError, "This upgrade code has already been used" if redeemed?
      raise AlreadyUpgradedError, "Your account is already Gold or higher" if redeemer.is_gold?

      user_upgrade = UserUpgrade.create!(recipient: redeemer, purchaser: redeemer, status: "processing", upgrade_type: "gold", payment_processor: "upgrade_code")
      user_upgrade.process_upgrade!("paid")

      update!(status: :redeemed, redeemer: redeemer, user_upgrade: user_upgrade)

      self
    end
  end
end
