# frozen_string_literal: true

class PasskeyPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def create?
    !user.is_anonymous?
  end

  def destroy?
    record.user == user
  end

  def rate_limit_for_write(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end
end
