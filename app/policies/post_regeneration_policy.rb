class PostRegenerationPolicy < ApplicationPolicy
  def create?
    user.is_moderator?
  end

  def permitted_attributes_for_create
    [:post_id, :category]
  end
end
