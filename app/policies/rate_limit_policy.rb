# frozen_string_literal: true

class RateLimitPolicy < ApplicationPolicy
  def index?
    true
  end

  def searchable_attributes
    %i[id created_at updated_at limited points action key]
  end
end
