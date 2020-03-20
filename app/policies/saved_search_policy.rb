class SavedSearchPolicy < ApplicationPolicy
  def index?
    user.is_member?
  end

  def create?
    user.is_member?
  end

  def update?
    record.user_id == user.id
  end

  def labels?
    index?
  end

  def permitted_attributes
    [:query, :label_string, :disable_labels]
  end
end
