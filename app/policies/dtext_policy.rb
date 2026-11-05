# frozen_string_literal: true

class DtextPolicy < ApplicationPolicy
  def create?
    true
  end

  def rate_limit_for_create(**_options)
    { rate: 30.0 / 1.minute, burst: 30 }
  end
end
