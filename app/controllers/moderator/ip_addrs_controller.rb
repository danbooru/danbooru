module Moderator
  class IpAddrsController < ApplicationController
    def index
      @search = IpAddrSearch.new(params[:search])
    end
    
    def search
    end
  end
end
