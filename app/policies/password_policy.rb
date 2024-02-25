# frozen_string_literal: true

class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id || can_change_user_passwords?
  end

  def can_change_user_passwords?
    user.is_owner?
  end
end
