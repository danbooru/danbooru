# frozen_string_literal: true

class SavedSearchPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def create?
    !user.is_anonymous?
  end

  def update?
    record.user_id == user.id
  end

  def labels?
    index?
  end

  def rate_limit_for_write(**_options)
    { action: "saved_searches:write", rate: 12.0 / 1.minute, burst: 80 } # 720 per hour, 800 in first hour
  end

  def permitted_attributes
    [:query, :label_string, :disable_labels]
  end
end
