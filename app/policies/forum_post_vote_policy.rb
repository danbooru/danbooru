class ForumPostVotePolicy < ApplicationPolicy
  def create?
    unbanned? && policy(record.forum_post).votable?
  end

  def destroy?
    unbanned? && record.creator_id == user.id
  end

  def permitted_attributes
    [:score]
  end
end
