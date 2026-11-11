# frozen_string_literal: true

class TagImplicationPolicy < TagRelationshipPolicy
  def destroy?
    user.is_admin?
  end
end
