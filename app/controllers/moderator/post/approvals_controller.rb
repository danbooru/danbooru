module Moderator
  module Post
    class ApprovalsController < ApplicationController
      before_filter :janitor_only
      
      def create
        @post = ::Post.find(params[:post_id])
        @post.approve!
      rescue ::Post::ApprovalError
      end
    end
  end
end
