# frozen_string_literal: true

class SessionLoaderPolicy < ApplicationPolicy
  # Login action
  def create?
    user.is_anonymous?
  end

  # Logout action
  def destroy?
    true
  end

  # Enter password before sensitive actions
  def reauthenticate?
    !user.is_anonymous?
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 5.minutes, burst: 5 }
  end

  def rate_limit_for_reauthenticate(**_options)
    { rate: 1.0 / 5.minutes, burst: 5, action: "sessions:create" }
  end

  def rate_limit_for_verify_totp(**_options)
    { rate: 1.0 / 30.minutes, burst: 50 }
  end

  alias_method :new?, :create?
  alias_method :verify_totp?, :create?
  alias_method :logout?, :destroy?
  alias_method :confirm_password?, :reauthenticate?
end
