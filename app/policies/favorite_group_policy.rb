# frozen_string_literal: true

class FavoriteGroupPolicy < ApplicationPolicy
  def show?
    true
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

  def permitted_attributes
    [:name, :post_ids_string, :post_ids, { post_ids: [] }]
  end
end
