# frozen_string_literal: true

class ReactionPolicy < ApplicationPolicy
  def create?
    unbanned? && policy(record.model).try(:reactable?)
  end

  def destroy?
    unbanned? && record.creator_id == user.id
  end

  def permitted_attributes
    [:model_id, :model_type, :reaction_id]
  end
end
