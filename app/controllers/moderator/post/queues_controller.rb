module Moderator
  module Post
    class QueuesController < ApplicationController
      respond_to :html, :json
      before_filter :post_approvers_only

      def show
        ::Post.without_timeout do
          @posts = ::Post.order("posts.id asc").pending_or_flagged.available_for_moderation(params[:hidden]).search(:tag_match => "#{params[:query]} status:any").paginate(params[:page], :limit => 25)
          @posts.each # hack to force rails to eager load
        end
        respond_with(@posts)
      end
    end
  end
end
