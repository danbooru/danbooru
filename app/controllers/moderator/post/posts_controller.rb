# frozen_string_literal: true

module Moderator
  module Post
    class PostsController < ApplicationController
      respond_to :html, :json, :xml, :js

      def confirm_move_favorites
        @post = authorize ::Post.find(params[:id])
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
        @post.expunge!(CurrentUser.user)
      end

      def ban
        @post = authorize ::Post.find(params[:id])
        @post.ban!(CurrentUser.user)

        respond_with(@post, notice: "Post was banned")
      end

      def unban
        @post = authorize ::Post.find(params[:id])
        @post.unban!(CurrentUser.user)

        respond_with(@post, notice: "Post was unbanned")
      end
    end
  end
end
