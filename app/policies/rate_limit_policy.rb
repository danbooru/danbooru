# frozen_string_literal: true

class RateLimitPolicy < ApplicationPolicy
  def index?
    true
  end

  def visible(relation)
    if user.is_owner?
      relation
    elsif user.is_anonymous?
      relation.none
    else
      relation.where(key: [user.cache_key])
    end
  end

  def searchable_attributes
    %i[id created_at updated_at limited points action key]
  end
end
