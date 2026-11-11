# frozen_string_literal: true

class SourcePolicy < ApplicationPolicy
  def show?
    !user.is_anonymous?
  end

  def rate_limit_for_show(**_options)
    { rate: 20.0 / 1.minute, burst: 50 }
  end
end
