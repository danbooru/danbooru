# frozen_string_literal: true

class UserNameChangeRequestPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def show?
    user.is_moderator? || (!user.is_anonymous? && !record.user.is_deleted?) || (record.user == user)
  end

  def create?
    unbanned? && (name_change.user == user || can_rename_user?)
  end

  def can_rename_user?
    user.is_moderator? && name_change.user.level < User::Levels::MODERATOR
  end

  def permitted_attributes_for_create
    [:user_id, :desired_name]
  end

  alias_method :name_change, :record
end
