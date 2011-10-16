module Moderator
  module Post
    class PostsController < ApplicationController
      before_filter :janitor_only, :only => [:delete, :undelete]
      before_filter :admin_only, :only => [:annihilate]
      
      def delete
        @post = ::Post.find(params[:id])
        @post.delete!
      end
      
      def undelete
        @post = ::Post.find(params[:id])
        @post.undelete!
      end
      
      def annihilate
        @post = ::Post.find(params[:id])
        @post.annihilate!
      end
    end
  end
end
