class LegacyController < ApplicationController
  before_filter :member_only, :only => [:create_post]

  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], format: "json")
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
    @upload.process!
  end

  def users
    @users = User.limit(100).search(params).paginate(params[:page])
  end

  def tags
    @tags = Tag.limit(100).search(params).paginate(params[:page], :limit => params[:limit])
  end

  def artists
    @artists = Artist.limit(100).search(params[:search]).paginate(params[:page])
  end

  def unavailable
    render :text => "this resource is no longer available", :status => 410
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
