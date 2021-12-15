# frozen_string_literal: true

class PostAppealPolicy < ApplicationPolicy
  def edit?
    update?
  end

  def update?
    unbanned? && record.pending? && record.creator_id == user.id
  end

  def permitted_attributes_for_create
    [:post_id, :reason]
  end

  def permitted_attributes_for_update
    [:reason]
  end
end
