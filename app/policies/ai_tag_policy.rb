# frozen_string_literal: true

class AITagPolicy < ApplicationPolicy
  def tag?
    unbanned? && record.post.present? && policy(record.post).update?
  end
end
