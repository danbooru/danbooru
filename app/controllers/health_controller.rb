# frozen_string_literal: true

class HealthController < ApplicationController
  respond_to :html, :json, :xml

  # Don't load current user in order to avoid making any database calls during health checks.
  anonymous_only

  after_action :skip_authorization

  # /up
  def show
    head 204
  end

  # /up/postgres
  def postgres
    status = ServerStatus.new.postgres_up? ? 204 : 503
    head status
  end

  # /up/redis
  def redis
    status = ServerStatus.new.redis_up? ? 204 : 503
    head status
  end
end
