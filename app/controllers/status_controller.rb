# frozen_string_literal: true

class StatusController < ApplicationController
  respond_to :html, :json, :xml

  # Don't try to load current user if database is down.
  anonymous_only if: -> { !postgres_up? }

  def show
    @status = authorize ServerStatus.new(request, include_sensitive_info: policy(ServerStatus).can_see_sensitive_info?)
    layout = @status.postgres_up? ? "default" : "blank"

    respond_with(@status, layout: layout)
  end

  private

  # Check the database once per request, since each check takes time to fail when the database is down.
  def postgres_up?
    @postgres_up = ServerStatus.new.postgres_up? if @postgres_up.nil?
    @postgres_up
  end
end
