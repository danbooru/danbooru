# frozen_string_literal: true

class CSPReportPolicy < ApplicationPolicy
  def create?
    true
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 1.second, burst: 30 }
  end
end
