# frozen_string_literal: true

class RelatedTagQueryPolicy < ApplicationPolicy
  def rate_limit_for_show(**_options)
    { rate: 60.0 / 1.minute, burst: 30 }
  end
end
