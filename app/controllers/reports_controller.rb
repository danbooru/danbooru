class ReportsController < ApplicationController
  def user_promotions
    @report = Reports::UserPromotions.new
  end
end
