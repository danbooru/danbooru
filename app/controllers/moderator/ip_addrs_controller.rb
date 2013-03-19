module Moderator
  class IpAddrsController < ApplicationController
    before_filter :janitor_only

    def index
      @search = IpAddrSearch.new(params[:search])
    end

    def search
    end
  end
end
