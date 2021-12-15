# frozen_string_literal: true

class StatusController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @status = ServerStatus.new(request)
    respond_with(@status)
  end
end
