module Moderator
  class IpAddrsController < ApplicationController
    respond_to :html, :json

    def index
      authorize IpAddress
      @search = IpAddrSearch.new(params[:search])
      @results = @search.execute
      respond_with(@results)
    end

    def search
    end
  end
end
