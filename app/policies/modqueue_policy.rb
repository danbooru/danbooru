# frozen_string_literal: true

class ModqueuePolicy < ApplicationPolicy
  def index?
    user.is_approver?
  end
end
