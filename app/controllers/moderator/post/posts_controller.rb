module Moderator
  module Post
    class PostsController < ApplicationController
      before_filter :approver_only, :only => [:delete, :undelete, :move_favorites, :replace, :ban, :unban, :confirm_delete, :confirm_move_favorites, :confirm_ban]
      before_filter :admin_only, :only => [:expunge]
      skip_before_filter :api_check

      respond_to :html, :json, :xml

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

      def replace
        @post = ::Post.find(params[:id])
        @post.replace!(params[:post][:source])

        respond_with(@post) do |format|
          format.html { redirect_to(@post) }
        end
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

        respond_to do |fmt|
          fmt.html do
            redirect_to(post_path(@post), :notice => "Post was banned")
          end

          fmt.js
        end
      end

      def unban
        @post = ::Post.find(params[:id])
        @post.unban!
        redirect_to(post_path(@post), :notice => "Post was unbanned")
      end
    end
  end
end
