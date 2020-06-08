class PostDisapprovalPolicy < ApplicationPolicy
  def create?
    user.is_approver?
  end

  def can_view_creator?
    user.is_moderator? || record.user_id == user.id
  end

  def permitted_attributes
    [:post_id, :reason, :message]
  end

  def api_attributes
    attributes = super
    attributes -= [:creator_id] unless can_view_creator?
    attributes
  end
end
