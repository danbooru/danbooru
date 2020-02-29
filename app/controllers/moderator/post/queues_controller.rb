module Moderator
  module Post
    class QueuesController < ApplicationController
      respond_to :html, :json
      before_action :approver_only
      skip_before_action :api_check

      def show
        @posts = ::Post.includes(:appeals, :disapprovals, :uploader, flags: [:creator]).reorder(id: :asc).pending_or_flagged.available_for_moderation(search_params[:hidden]).tag_match(search_params[:tags]).paginated_search(params, count_pages: true)
        respond_with(@posts)
      end
    end
  end
end
