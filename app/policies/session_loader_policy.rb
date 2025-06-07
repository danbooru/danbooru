# frozen_string_literal: true

class SessionLoaderPolicy < ApplicationPolicy
  # Login action
  def create?
    true
  end

  # Logout action
  def destroy?
    true
  end

  # Enter password before sensitive actions
  def reauthenticate?
    !user.is_anonymous?
  end

  alias_method :new?, :create?
  alias_method :verify_totp?, :create?
  alias_method :logout?, :destroy?
  alias_method :confirm_password?, :reauthenticate?
end
