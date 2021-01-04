class StatusController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @status = ServerStatus.new
    respond_with(@status)
  end
end
