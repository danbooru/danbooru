module Moderator
  class DashboardsController < ApplicationController
    def show
      @dashboard = Moderator::Dashboard::Report.new(**search_params.to_h.symbolize_keys)
    end
  end
end
