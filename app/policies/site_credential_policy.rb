# frozen_string_literal: true

class SiteCredentialPolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def show?
    if record.is_public?
      user.is_admin?
    else
      record.creator_id == user.id
    end
  end

  def create?
    user.is_admin?
  end

  def update?
    if record.is_public?
      user.is_admin?
    else
      record.creator_id == user.id
    end
  end

  def destroy?
    if record.is_public?
      user.is_owner?
    else
      record.creator_id == user.id
    end
  end

  def permitted_attributes_for_create
    [:site, :is_enabled, { credential: {} }]
  end

  def permitted_attributes_for_update
    [:is_enabled]
  end
end
