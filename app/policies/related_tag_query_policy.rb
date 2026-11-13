# frozen_string_literal: true

class RelatedTagQueryPolicy < ApplicationPolicy
  # The maximum number of posts to sample when finding related tags.
  def max_search_sample_size
    if user.is_builder?
      100_000
    else
      10_000
    end
  end

  def rate_limit_for_show(**_options)
    { rate: 60.0 / 1.minute, burst: 30 }
  end
end
