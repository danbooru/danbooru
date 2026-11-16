# frozen_string_literal: true

class UserNameChangeRequestPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def show?
    user.is_moderator? || (!user.is_anonymous? && !record.user.is_deleted?) || (record.user == user)
  end

  def create?
    (user.name_errors.present? || unbanned?) && (name_change.user == user || can_rename_user?)
  end

  def can_rename_user?
    user.is_moderator? && name_change.user.level < User::Levels::MODERATOR
  end

  def permitted_attributes_for_create
    [:user_id, :desired_name]
  end

  alias_method :name_change, :record

  def visible(relation)
    if user.is_moderator?
      relation
    elsif user.is_anonymous?
      relation.none
    else
      relation.where(user: User.undeleted)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at user original_name desired_name]
  end
end
