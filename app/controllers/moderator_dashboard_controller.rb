# frozen_string_literal: true

class ModeratorDashboardController < ApplicationController
  def show
    @dashboard = authorize ModeratorDashboard.new(**search_params.to_h.symbolize_keys)
  end
end
