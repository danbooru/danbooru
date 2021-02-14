class ApiKeyPolicy < ApplicationPolicy
  def create?
    !user.is_anonymous?
  end

  def index?
    !user.is_anonymous?
  end

  def destroy?
    record.user == user
  end

  def api_attributes
    super - [:key]
  end
end
