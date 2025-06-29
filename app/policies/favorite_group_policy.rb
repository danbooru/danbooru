# frozen_string_literal: true

class FavoriteGroupPolicy < ApplicationPolicy
  def show?
    record.creator_id == user.id || record.is_public
  end

  def create?
    !user.is_anonymous?
  end

  def update?
    record.creator_id == user.id
  end

  def add_post?
    update?
  end

  def remove_post?
    update?
  end

  def can_enable_privacy?
    record.creator.is_gold?
  end

  def rate_limit_for_create(**_options)
    if record.invalid?
      { action: "favorite_group:create:invalid", rate: 1.0 / 1.second, burst: 10 }
    else
      { action: "favorite_group:create", rate: 1.0 / 1.minute, burst: 10 } # 60 per hour, 70 in first hour
    end
  end

  def permitted_attributes
    [:name, :post_ids_string, :is_public, :is_private, :post_ids, { post_ids: [] }]
  end
end
