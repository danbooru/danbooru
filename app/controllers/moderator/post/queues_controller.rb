module Moderator
  module Post
    class QueuesController < ApplicationController
      respond_to :html, :json
      before_action :approver_only
      skip_before_action :api_check

      def show
        if search_params[:per_page]
          cookies.permanent["mq_per_page"] = search_params[:per_page]
        end

        ::Post.without_timeout do
          @posts = ::Post.includes(:disapprovals, :uploader).order("posts.id asc").pending_or_flagged.available_for_moderation(search_params[:hidden]).tag_match(search_params[:tags]).paginate(params[:page], :limit => per_page)
          @posts.each # hack to force rails to eager load
        end
        respond_with(@posts)
      end

      protected

      def per_page
        cookies["mq_per_page"] || search_params[:per_page] || 25
      end
    end
  end
end
