module Moderator
  class IpAddrsController < ApplicationController
    before_action :moderator_only
    respond_to :html, :json

    def index
      @search = IpAddrSearch.new(params[:search])
      @results = @search.execute
      respond_with(@results)
    end

    def search
    end
  end
end
