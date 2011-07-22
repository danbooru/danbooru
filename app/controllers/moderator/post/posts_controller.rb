module Moderator
  module Post
    class PostsController < ApplicationController
      def delete
        @post = ::Post.find(params[:id])
        @post.delete!
      end
      
      def undelete
        @post = ::Post.find(params[:id])
        @post.undelete!
      end
    end
  end
end
