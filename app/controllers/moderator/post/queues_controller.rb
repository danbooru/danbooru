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

        @posts = ::Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).reorder(id: :asc).pending_or_flagged.available_for_moderation(search_params[:hidden]).tag_match(search_params[:tags]).paginate(params[:page], :limit => per_page)
        respond_with(@posts)
      end

      protected

      def per_page
        cookies["mq_per_page"] || search_params[:per_page] || 25
      end
    end
  end
end
