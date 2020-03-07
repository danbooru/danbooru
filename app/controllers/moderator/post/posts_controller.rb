module Moderator
  module Post
    class PostsController < ApplicationController
      before_action :approver_only, :only => [:delete, :move_favorites, :ban, :unban, :confirm_delete, :confirm_move_favorites]
      before_action :admin_only, :only => [:expunge]
      skip_before_action :api_check

      respond_to :html, :json, :xml, :js

      def confirm_delete
        @post = ::Post.find(params[:id])
      end

      def delete
        @post = ::Post.find(params[:id])
        if params[:commit] == "Delete"
          @post.delete!(params[:reason], :move_favorites => params[:move_favorites].present?)
        end
        redirect_to(post_path(@post))
      end

      def confirm_move_favorites
        @post = ::Post.find(params[:id])
      end

      def move_favorites
        @post = ::Post.find(params[:id])
        if params[:commit] == "Submit"
          @post.give_favorites_to_parent
        end
        redirect_to(post_path(@post))
      end

      def expunge
        @post = ::Post.find(params[:id])
        @post.expunge!
      end

      def ban
        @post = ::Post.find(params[:id])
        @post.ban!
        flash[:notice] = "Post was banned"

        respond_with(@post)
      end

      def unban
        @post = ::Post.find(params[:id])
        @post.unban!
        flash[:notice] = "Post was banned"

        respond_with(@post)
      end
    end
  end
end
