module Moderator
  module Post
    class PostsController < ApplicationController
      skip_before_action :api_check
      respond_to :html, :json, :xml, :js

      def confirm_move_favorites
        @post = ::Post.find(params[:id])
      end

      def move_favorites
        @post = authorize ::Post.find(params[:id])
        if params[:commit] == "Submit"
          @post.give_favorites_to_parent
        end
        redirect_to(post_path(@post))
      end

      def expunge
        @post = authorize ::Post.find(params[:id])
        @post.expunge!
      end

      def ban
        @post = authorize ::Post.find(params[:id])
        @post.ban!
        flash[:notice] = "Post was banned"

        respond_with(@post)
      end

      def unban
        @post = authorize ::Post.find(params[:id])
        @post.unban!
        flash[:notice] = "Post was unbanned"

        respond_with(@post)
      end
    end
  end
end
