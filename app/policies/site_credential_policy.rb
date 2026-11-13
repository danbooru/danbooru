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
    [:site, :is_enabled, { credential: {}}]
  end

  def permitted_attributes_for_update
    [:is_enabled]
  end

  def visible(relation)
    if user.is_admin?
      relation.where(creator: user).or(relation.is_public)
    else
      relation.where(creator: user)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at creator site is_enabled is_public status usage_count error_count last_used_at last_error_at credential metadata]
  end
end
