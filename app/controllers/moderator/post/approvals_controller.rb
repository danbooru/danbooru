module Moderator
  module Post
    class ApprovalsController < ApplicationController
      def create
        @post = ::Post.find(params[:post_id])
        @post.approve!
      end
    end
  end
end
