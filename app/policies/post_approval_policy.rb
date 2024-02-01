# frozen_string_literal: true

class PostApprovalPolicy < ApplicationPolicy
  def create?
    user.is_approver?
  end

  def can_approve_own_uploads?
    user.is_admin?
  end

  def can_approve_same_post_twice?
    user.is_admin?
  end
end
