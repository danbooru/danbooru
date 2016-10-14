module Moderator
  module Post
    class ApprovalsController < ApplicationController
      before_filter :approver_only

      def create
        cookies.permanent[:moderated] = Time.now.to_i
        @post = ::Post.find(params[:post_id])
        if @post.is_deleted? || @post.is_flagged? || @post.is_pending?
          @post.approve!
        end
      rescue ::Post::ApprovalError
      end
    end
  end
end
