# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def rate_limit_for_show(**_options)
    { rate: 1.0 / 3.seconds, burst: 15 }
  end
end
