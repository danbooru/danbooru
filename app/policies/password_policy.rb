# frozen_string_literal: true

class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id || user.is_owner?
  end
end
