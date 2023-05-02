# frozen_string_literal: true

class MetricsController < ApplicationController
  respond_to :text, :json, :xml

  def index
    @metrics = ApplicationMetrics.application_metrics

    expires_in 1.minute, public: true unless response.cache_control.present?
    respond_with(@metrics) do |format|
      format.text { render plain: @metrics.to_prom }
    end
  end

  def instance
    @metrics = ApplicationMetrics.instance_metrics

    expires_in 1.minute, public: true unless response.cache_control.present?
    respond_with(@metrics) do |format|
      format.text { render plain: @metrics.to_prom }
    end
  end
end
