class ReportsController < ApplicationController
  before_filter :janitor_only

  def user_promotions
    @report = Reports::UserPromotions.new
  end
end
