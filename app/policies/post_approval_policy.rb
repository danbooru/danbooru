class PostApprovalPolicy < ApplicationPolicy
  def create?
    user.is_approver?
  end
end
