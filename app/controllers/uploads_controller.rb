class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js

  def new
    @upload = Upload.new
    @upload_notice_wiki = WikiPage.titled(Danbooru.config.upload_notice_wiki_page).first
    if params[:url]
      @normalized_url = params[:url]
      headers = default_headers()
      data = {}

      Downloads::RewriteStrategies::Base.strategies.each do |strategy|
        @normalized_url, headers, data = strategy.new(@normalized_url).rewrite(@normalized_url, headers, data)
      end

      @post = find_post_by_url(@normalized_url)

      begin
        @source = Sources::Site.new(params[:url], :referer_url => params[:ref])
        @remote_size = Downloads::File.new(@normalized_url, ".").size
      rescue Exception
      end
    end
    respond_with(@upload)
  end

  def batch
    @source = Sources::Site.new(params[:url], :referer_url => params[:ref])
    @source.get
    @urls = @source.image_urls
  end

  def image_proxy
    resp = ImageProxy.get_image(params[:url])
    send_data resp.body, :type => resp.content_type, :disposition => "inline"
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
    save_recent_tags
    respond_with(@upload)
  end

  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end

protected
  def find_post_by_url(normalized_url)
    if normalized_url.nil?
      Post.where(source: params[:url]).first
    else
      Post.where(source: [params[:url], @normalized_url]).first
    end
  end

  def default_headers
    {
      "User-Agent" => "#{Danbooru.config.safe_app_name}/#{Danbooru.config.version}"
    }
  end

  def save_recent_tags
    if @upload
      tags = Tag.scan_tags(@upload.tag_string)
      tags = (TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])).compact.uniq.slice(0, 30)
      cookies[:recent_tags] = tags.join(" ")
      cookies[:recent_tags_with_categories] = Tag.categories_for(tags).to_a.flatten.join(" ")
    end
  end
end
