class LegacyController < ApplicationController
  before_filter :member_only, :only => [:create_post]
  rescue_from PostSets::SearchError, :with => :error

  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit])
    @posts = @post_set.posts
  end
  
  def create_post
    @upload = Upload.new
    @upload.server = Socket.gethostname
    @upload.file = params[:post][:file]
    @upload.source = params[:post][:source]
    @upload.tag_string = params[:post][:tags]
    @upload.parent_id = params[:post][:parent_id]
    @upload.rating = params[:post][:rating][0].downcase
    @upload.md5_confirmation = params[:md5] if params[:md5].present?
    @upload.save
    @upload.delay.process!
  end
  
  def users
    @users = User.search(params).limit(100)
  end
  
  def tags
    @tags = Tag.search(params).limit(100)
  end
  
  def unavailable
    render :text => "this resource is no longer available", :status => 410
  end
  
  def error
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
