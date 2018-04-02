module Moderator
  class DashboardsController < ApplicationController
    before_action :member_only
    helper :post_flags, :post_appeals

    def show
      @dashboard = Moderator::Dashboard::Report.new(params[:min_date] || 2.days.ago.to_date, params[:max_level] || 20)
    end
  end
end
