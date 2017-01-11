module Moderator
  module Post
    class DisapprovalsController < ApplicationController
      before_filter :approver_only
      skip_before_filter :api_check

      def create
        cookies.permanent[:moderated] = Time.now.to_i
        @post = ::Post.find(params[:post_id])
        @post_disapproval = PostDisapproval.create(:post => @post, :user => CurrentUser.user, :reason => params[:reason] || "disinterest", :message => params[:message])
      end
    end
  end
end
