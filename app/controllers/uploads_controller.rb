class UploadsController < ApplicationController
  before_filter :member_only
  after_filter :save_recent_tags, :only => [:create]
  respond_to :html, :xml, :json, :js
  rescue_from Upload::Error, :with => :rescue_exception

  def new
    @upload = Upload.new
    if params[:url]
      @normalized_url = params[:url]

      headers = {
        "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
      }
      Downloads::Strategies::Base.strategies.each do |strategy|
        @normalized_url, headers = strategy.new.rewrite(@normalized_url, headers)
      end

      @post = Post.find_by_source(@normalized_url)

      begin
        @source = Sources::Site.new(params[:url])
      rescue Exception
      end
    end
    respond_with(@upload)
  end

  def index
    @search = Upload.search(params[:search])
    @uploads = @search.order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@uploads) do |format|
      format.xml do
        render :xml => @uploads.to_xml(:root => "uploads")
      end
    end
  end

  def show
    @upload = Upload.find(params[:id])
    respond_with(@upload) do |format|
      format.html do
        if @upload.is_completed? && @upload.post_id
          redirect_to(post_path(@upload.post_id))
        end
      end
    end
  end

  def create
    @upload = Upload.create(params[:upload].merge(:server => Socket.gethostname))
    @upload.process! if @upload.errors.empty?
    respond_with(@upload)
  end

  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end

protected
  def save_recent_tags
    if @upload
      tags = Tag.scan_tags(@upload.tag_string)
      tags = (TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])).uniq.slice(0, 30)
      cookies[:recent_tags] = tags.join(" ")
      cookies[:recent_tags_with_categories] = Tag.categories_for(tags).to_a.flatten.join(" ")
    end
  end
end
