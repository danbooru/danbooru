# frozen_string_literal: true

class TagAliasPolicy < ApplicationPolicy
  def destroy?
    user.is_admin?
  end
end
