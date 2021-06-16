class ApiKeyPolicy < ApplicationPolicy
  def new?
    !user.is_anonymous?
  end

  def create?
    !user.is_anonymous?
  end

  def index?
    !user.is_anonymous?
  end

  def edit?
    record.user == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def permitted_attributes
    [:name, :permitted_ip_addresses, { permissions: [] }]
  end

  def api_attributes
    super - [:key]
  end
end
