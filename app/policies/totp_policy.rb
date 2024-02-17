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
end
