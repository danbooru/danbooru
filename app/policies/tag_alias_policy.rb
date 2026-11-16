# frozen_string_literal: true

class TagAliasPolicy < TagRelationshipPolicy
  def destroy?
    user.is_admin?
  end
end
