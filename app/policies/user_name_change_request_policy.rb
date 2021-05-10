class UserNameChangeRequestPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def show?
    user.is_moderator? || (!user.is_anonymous? && !record.user.is_deleted?) || (record.user == user)
  end

  def permitted_attributes
    [:desired_name, :desired_name_confirmation]
  end
end
