module Moderator
  class DashboardsController < ApplicationController
    before_filter :janitor_only
    
    def show
      @dashboard = ModeratorDashboard.new(params[:min_date] || 2.days.ago.to_date, params[:max_level] || 20)
    end
  end
end
