class ReportsController < ApplicationController
  def user_promotions
    @report = Reports::UserPromotions.new
  end

  def janitor_trials
    @report = Reports::JanitorTrials.new
  end

  def contributors
    @report = Reports::Contributors.new
  end

  def uploads
    @report = Reports::Uploads.new(params[:min_date], params[:max_date], params[:queries])
  end
end
