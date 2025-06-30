# frozen_string_literal: true

class AITagPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def tag?
    user.is_moderator? && record.post.present?
  end
end
