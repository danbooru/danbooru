module Admin
  class DashboardsController < ApplicationController
    def show
      @dashboard = AdminDashboard.new
    end
  end
end
