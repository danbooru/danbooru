# frozen_string_literal: true

class IqdbClientPolicy < ApplicationPolicy
  def index?
    !user.is_anonymous?
  end

  def rate_limit_for_show(**_options)
    { rate: 1.0 / 1.second, burst: 20 }
  end

  alias_method :rate_limit_for_create, :rate_limit_for_show
end
