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

  def can_enable_privacy?
    record.creator.is_gold?
  end

  def permitted_attributes
    [:name, :post_ids_string, :is_public, :is_private, :post_ids, { post_ids: [] }]
  end
end
