class PostsController < ApplicationController
  before_filter :member_only, :except => [:show, :index]
  after_filter :save_recent_tags, :only => [:update]
  respond_to :html, :xml, :json
  
  def index
    @posts = Post.search(params[:search]).paginate(params[:page])
    respond_with(@posts)
  end
  
  def show
    @post = Post.find(params[:id])
    @post_flag = PostFlag.new(:post_id => @post.id)
    @post_appeal = PostAppeal.new(:post_id => @post.id)
    respond_with(@post)
  end
  
  def update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
    respond_with(@post)
  end
  
  def revert
    @post = Post.find(params[:id])
    @version = PostVersion.find(params[:version_id])
    @post.revert_to!(@version)
    respond_with(@post)
  end

private
  def extend_post_set(post_set)
    @post_set.extend(PostSets::Post)
    
    if use_sequential_paginator?
      @post_set.extend(PostSets::Sequential)
    else
      @post_set.extend(PostSets::Numbered)
    end
  end
  
  def use_sequential_paginator?
    if params[:page].to_i > 1000
      true
    else
      false
    end
  end

  def save_recent_tags
    if params[:tags] || (params[:post] && params[:post][:tags])
      tags = Tag.scan_tags(params[:tags] || params[:post][:tags])
      tags = TagAlias.to_aliased(tags) + Tag.scan_tags(session[:recent_tags])
      session[:recent_tags] = tags.uniq.slice(0, 40).join(" ")
    end
  end
end
