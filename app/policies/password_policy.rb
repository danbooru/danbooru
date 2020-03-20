class PasswordPolicy < ApplicationPolicy
  def update?
    record.id == user.id || user.is_admin?
  end

  def permitted_attributes
    [:signed_user_id, :old_password, :password, :password_confirmation]
  end
end
