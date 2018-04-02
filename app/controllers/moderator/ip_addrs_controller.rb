module Moderator
  class IpAddrsController < ApplicationController
    before_action :moderator_only

    def index
      @search = IpAddrSearch.new(params[:search])
      @results = @search.execute
    end

    def search
    end
  end
end
