# frozen_string_literal: true

class NewsUpdatePolicy < ApplicationPolicy
  def index?
    user.is_admin?
  end

  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def permitted_attributes
    [:message, :duration, :duration_in_days, :is_deleted]
  end

  def visible(relation)
    if user.is_admin?
      relation
    else
      relation.none
    end
  end

  def searchable_attributes
    %i[id created_at updated_at message creator updater]
  end
end
