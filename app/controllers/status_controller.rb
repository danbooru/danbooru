# frozen_string_literal: true

class StatusController < ApplicationController
  respond_to :html, :json, :xml

  # Don't try to load current user if database is down.
  anonymous_only if: -> { !ServerStatus.new.postgres_up? }

  def show
    @status = authorize ServerStatus.new(request)
    layout = @status.postgres_up? ? "default" : "blank"

    respond_with(@status, layout: layout)
  end
end
