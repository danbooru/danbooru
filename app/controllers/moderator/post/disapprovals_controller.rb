module Moderator
  module Post
    class DisapprovalsController < ApplicationController
      before_filter :janitor_only

      def create
        @post = ::Post.find(params[:post_id])
        @post_disapproval = PostDisapproval.create(:post => @post, :user => CurrentUser.user)
      end
    end
  end
end
