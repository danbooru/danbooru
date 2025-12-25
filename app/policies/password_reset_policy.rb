# frozen_string_literal: true

class PasswordResetPolicy < ApplicationPolicy
  def show?
    user.is_anonymous?
  end

  def create?
    user.is_anonymous?
  end

  def update?
    user.is_anonymous?
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.minute, burst: 5 }
  end

  def rate_limit_for_update(**_options)
    { rate: 1.0 / 30.minutes, burst: 50 }
  end
end
