# frozen_string_literal: true

class SiteCredentialPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def show?
    user.is_admin? || record.creator_id == user.id
  end

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin? || record.creator_id == user.id
  end

  def destroy?
    user.is_admin? || record.creator_id == user.id
  end

  def permitted_attributes_for_create
    [:site, :is_enabled, { credential: {} }]
  end

  def permitted_attributes_for_update
    [:is_enabled, { credential: {} }]
  end
end
