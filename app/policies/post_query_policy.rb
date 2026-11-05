# frozen_string_literal: true

class PostQueryPolicy < ApplicationPolicy
  def posts?
    true
  end

  def rate_limit_for_posts(**_options)
    { rate: 60.0 / 1.minute, burst: 15 }
  end

  # Whether the user can ask for exact, uncached post counts. These counts are slow, so they're restricted.
  def can_use_exact_counts?
    user.is_builder?
  end
end
