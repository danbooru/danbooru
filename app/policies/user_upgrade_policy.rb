# frozen_string_literal: true

class UserUpgradePolicy < ApplicationPolicy
  def create?
    false
  end

  def new?
    true
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end

  def show?
    record.recipient == user || record.purchaser == user
  end

  def refund?
    false
  end

  def receipt?
    record.purchaser == user && record.has_receipt?
  end

  def payment?
    false
  end

  def visible(relation)
    relation.where(recipient: user).or(relation.where(purchaser: user))
  end

  def searchable_attributes
    %i[id created_at updated_at upgrade_type status transaction_id payment_processor recipient purchaser]
  end
end
