module Moderator
  module Post
    class QueuesController < ApplicationController
      respond_to :html, :json
      before_filter :post_approvers_only

      def show
        if params[:per_page]
          session["mq_per_page"] = params[:per_page]
        end

        ::Post.without_timeout do
          @posts = ::Post.order("posts.id asc").pending_or_flagged.available_for_moderation(params[:hidden]).search(:tag_match => "#{params[:query]} status:any").paginate(params[:page], :limit => per_page)
          @posts.each # hack to force rails to eager load
        end
        respond_with(@posts)
      end

    protected

      def per_page
        session["mq_per_page"] || params[:per_page] || 25
      end
    end
  end
end
