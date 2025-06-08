# frozen_string_literal: true

class TOTPPolicy < ApplicationPolicy
  def edit?
    record == user
  end

  def update?
    record == user
  end

  def destroy?
    record == user
  end

  def rate_limit_for_write(**_options)
    { rate: 1.0 / 1.minute, burst: 10 }
  end
end
