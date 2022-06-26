# frozen_string_literal: true

class AITagPolicy < ApplicationPolicy
  def index?
    true
  end

  def tag?
    unbanned? && record.post.present? && policy(record.post).update?
  end
end
