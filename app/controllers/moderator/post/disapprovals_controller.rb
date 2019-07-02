module Moderator
  module Post
    class DisapprovalsController < ApplicationController
      before_action :approver_only
      skip_before_action :api_check
      respond_to :js, :json, :xml

      def create
        cookies.permanent[:moderated] = Time.now.to_i
        @post_disapproval = PostDisapproval.create(post_disapproval_params)
        respond_with(@post_disapproval, location: moderator_post_disapprovals_path)
      end

      def index
        @post_disapprovals = PostDisapproval.paginate(params[:page])
      end

      private

      def post_disapproval_params
        params.require(:post_disapproval).permit(%i[post_id reason message])
      end
    end
  end
end
