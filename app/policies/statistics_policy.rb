# frozen_string_literal: true

class StatisticsPolicy < ApplicationPolicy
  def purge_cache?
    user.is_admin?
  end
end
