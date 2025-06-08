# frozen_string_literal: true

class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id || can_change_user_passwords?
  end

  def can_change_user_passwords?
    user.is_owner?
  end

  def rate_limit_for_update(**_options)
    { rate: 1.0 / 10.minutes, burst: 20 }
  end
end
