# frozen_string_literal: true

class MetricsController < ApplicationController
  respond_to :text, :json, :xml

  def index
    @metrics = ApplicationMetrics.new.calculate

    expires_in 1.minute, public: true unless response.cache_control.present?
    respond_with(@metrics) do |format|
      format.text { render plain: @metrics.map(&:to_prom).join("\n\n") }
    end
  end
end
