module Admin
  class DashboardsController < ApplicationController
    before_filter :admin_only
    
    def show
      @dashboard = AdminDashboard.new
    end
  end
end
