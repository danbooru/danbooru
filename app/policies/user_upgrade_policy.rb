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
    record.recipient == user || record.purchaser == user || user.is_superadmin?
  end

  def refund?
    user.is_superadmin? && record.complete?
  end

  def receipt?
    (record.purchaser == user || user.is_superadmin?) && record.has_receipt?
  end

  def payment?
    user.is_superadmin? && record.has_payment?
  end

  def visible(relation)
    if user.is_superadmin?
      relation
    else
      relation.where(recipient: user).or(relation.where(purchaser: user))
    end
  end

  def searchable_attributes
    %i[id created_at updated_at upgrade_type status transaction_id payment_processor recipient purchaser]
  end
end
