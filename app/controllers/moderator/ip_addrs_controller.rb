module Moderator
  class IpAddrsController < ApplicationController
    before_filter :moderator_only

    def index
      @search = IpAddrSearch.new(params[:search])
    end

    def search
    end
  end
end
