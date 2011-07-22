module Moderator
  module Post
    class DisapprovalsController < ApplicationController
      def create
        @post = ::Post.find(params[:post_id])
        @post_disapproval = PostDisapproval.create(:post => @post, :user => CurrentUser.user)
        if @post_disapproval.errors.any?
          raise ::Post::DisapprovalError.new(@post_disapproval.errors.full_messages)
        end

        # js: redirect to dashboard
      end
    end
  end
end
