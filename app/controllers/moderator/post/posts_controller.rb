module Moderator
  module Post
    class PostsController < ApplicationController
      before_filter :post_approvers_only, :only => [:delete, :undelete, :move_favorites, :ban, :unban, :confirm_delete, :confirm_move_favorites, :confirm_ban]
      before_filter :admin_only, :only => [:expunge]
      rescue_from ::PostFlag::Error, ::Post::ApprovalError, :with => :rescue_exception

      def confirm_delete
        @post = ::Post.find(params[:id])
      end

      def delete
        @post = ::Post.find(params[:id])
        if params[:commit] == "Delete"
          @post.flag!(params[:reason], :is_deletion => true)
          @post.delete!(:reason => params[:reason], :move_favorites => params[:move_favorites].present?)
        end
        redirect_to(post_path(@post))
      end

      def undelete
        @post = ::Post.find(params[:id])
        @post.undelete!
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
      rescue StandardError => x
        @error = x
      end

      def confirm_ban
        @post = ::Post.find(params[:id])
      end

      def ban
        @post = ::Post.find(params[:id])
        if params[:commit] == "Ban"
          @post.ban!
        end
        redirect_to(post_path(@post), :notice => "Post was banned")
      end

      def unban
        @post = ::Post.find(params[:id])
        @post.unban!
        redirect_to(post_path(@post), :notice => "Post was unbanned")
      end
    end
  end
end
