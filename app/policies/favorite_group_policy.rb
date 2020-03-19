class FavoriteGroupPolicy < ApplicationPolicy
  def show?
    record.creator_id == user.id || record.is_public
  end

  def create?
    user.is_member?
  end

  def update?
    record.creator_id == user.id
  end

  def add_post?
    update?
  end

  def permitted_attributes
    [:name, :post_ids_string, :is_public, :post_ids, post_ids: []]
  end
end
