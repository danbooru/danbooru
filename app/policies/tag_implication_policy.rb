# frozen_string_literal: true

class TagImplicationPolicy < ApplicationPolicy
  def destroy?
    user.is_admin?
  end
end
