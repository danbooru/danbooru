module Moderator
  module Post
    class DashboardsController < ApplicationController
      respond_to :html, :json
      before_filter :janitor_only
      
      def show
        @search = ::Post.order("id asc").pending_or_flagged.available_for_moderation.search(:tag_match => params[:query])
        @posts = @search.paginate(params[:page])
        respond_with(@posts)
      end
    end
  end
end
