# frozen_string_literal: true

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

  def visible(relation)
    if user.is_owner?
      relation
    else
      relation.where(user: user)
    end
  end

  def searchable_attributes
    %i[id created_at updated_at user]
  end

  def api_attributes
    super - [:key]
  end
end
