# frozen_string_literal: true

class PasswordResetPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def update?
    user.is_anonymous?
  end
end
