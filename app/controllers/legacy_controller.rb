class LegacyController < ApplicationController
  before_action :member_only, :only => [:create_post]
  respond_to :json, :xml

  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], format: "json")
    @posts = @post_set.posts.map(&:legacy_attributes)

    respond_with(@posts) do |format|
      format.xml do
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct!
        xml.posts do
          @posts.each { |attrs| xml.post(attrs) }
        end
        render xml: xml.target!
      end
    end
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
    @artists = Artist.limit(100).search(search_params).paginate(params[:page])
  end

  def unavailable
    render :text => "this resource is no longer available", :status => 410
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
