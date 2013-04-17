module Moderator
  module Post
    class PostsController < ApplicationController
      before_filter :janitor_only, :only => [:delete, :undelete, :ban, :unban, :confirm_delete, :confirm_ban]
      before_filter :admin_only, :only => [:expunge]
      rescue_from ::PostFlag::Error, :with => :rescue_exception

      def confirm_delete
        @post = ::Post.find(params[:id])
      end

      def delete
        @post = ::Post.find(params[:id])
        if params[:commit] == "Delete"
          @post.flag!(params[:reason])
          @post.delete!
        end
        redirect_to(post_path(@post))
      end

      def undelete
        @post = ::Post.find(params[:id])
        @post.undelete!
      end

      def expunge
        @post = ::Post.find(params[:id])
        @post.expunge!
      end

      def confirm_ban
        @post = ::Post.find(params[:id])
      end

      def ban
        @post = ::Post.find(params[:id])
        if params[:commit] == "Ban"
          @post.update_column(:is_banned, true)
        end
        redirect_to(post_path(@post), :notice => "Post was banned")
      end

      def unban
        @post = ::Post.find(params[:id])
        @post.update_attribute(:is_banned, false)
        redirect_to(post_path(@post), :notice => "Post was unbanned")
      end
    end
  end
end
