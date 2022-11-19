# frozen_string_literal: true

class StatisticsController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @statistics = ServerStatistics.cached
    respond_with(@statistics)
  end

  def purge_cache
    @statistics = authorize ServerStatistics.purge_cache, policy_class: StatisticsPolicy
    respond_with(@statistics, location: stats_path)
  end
end
