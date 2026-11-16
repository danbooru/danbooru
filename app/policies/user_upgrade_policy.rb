# frozen_string_literal: true

class UserUpgradePolicy < ApplicationPolicy
  def create?
    !user.is_anonymous?
  end

  def new?
    true
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
end
