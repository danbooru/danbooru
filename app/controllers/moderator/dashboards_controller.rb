module Moderator
  class DashboardsController < ApplicationController
    before_action :member_only
    helper :post_flags, :post_appeals

    def show
      @dashboard = Moderator::Dashboard::Report.new(**search_params.to_h.symbolize_keys)
    end
  end
end
