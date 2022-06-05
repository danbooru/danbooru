# frozen_string_literal: true

class PostApprovalPolicy < ApplicationPolicy
  def create?
    user.is_approver?
  end

  def can_bypass_approval_limits?
    user.is_admin?
  end
end
