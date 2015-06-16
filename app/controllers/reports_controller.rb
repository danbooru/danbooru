class ReportsController < ApplicationController
  def user_promotions
    @report = Reports::UserPromotions.new
  end

  def janitor_trials
    @report = Reports::JanitorTrials.new
  end
end
