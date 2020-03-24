class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id || user.is_admin?
  end
end
