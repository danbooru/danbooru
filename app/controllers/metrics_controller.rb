# frozen_string_literal: true

class MetricsController < ApplicationController
  respond_to :text, :json, :xml

  def index
    @metrics = authorize ApplicationMetrics.application_metrics, policy_class: MetricsPolicy

    expires_in 1.minute, public: true unless response.cache_control.present?
    respond_with(@metrics) do |format|
      format.text { render plain: @metrics.to_prom }
    end
  end

  def instance
    @metrics = authorize ApplicationMetrics.instance_metrics, policy_class: MetricsPolicy

    expires_in 1.minute, public: true unless response.cache_control.present?
    respond_with(@metrics) do |format|
      format.text { render plain: @metrics.to_prom }
    end
  end
end
