# frozen_string_literal: true

class ExplorePostPolicy < ApplicationPolicy
  alias_method :popular?, :index?
  alias_method :viewed?, :index?
  alias_method :searches?, :index?
  alias_method :missed_searches?, :index?

  def rate_limit_for_popular(request:)
    { rate: 1.0 / 1.minute, burst: 50 } if request.format.json?
  end
end
