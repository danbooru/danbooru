class UploadsController < ApplicationController
  before_filter :member_only, except: [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @upload = Upload.new
    @upload_notice_wiki = WikiPage.titled(Danbooru.config.upload_notice_wiki_page).first
    if params[:url]
      download = Downloads::File.new(params[:url], ".")
      @normalized_url, _, _ = download.before_download(params[:url], {})
      @post = find_post_by_url(@normalized_url)

      begin
        @source = Sources::Site.new(params[:url], :referer_url => params[:ref])
        @remote_size = download.size
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
    @uploads = @search.paginate(params[:page], :limit => params[:limit])
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
    @upload = Upload.create(upload_params)

    if @upload.errors.empty?
      post = @upload.process!

      if post.present? && post.valid? && post.warnings.any?
        flash[:notice] = post.warnings.full_messages.join(".\n \n")
      end
    end

    save_recent_tags
    respond_with(@upload)
  end

  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end

  private

  def find_post_by_url(normalized_url)
    if normalized_url.nil?
      Post.where("SourcePattern(lower(posts.source)) = ?", params[:url]).first
    else
      Post.where("SourcePattern(lower(posts.source)) IN (?)", [params[:url], @normalized_url]).first
    end
  end

  def save_recent_tags
    if @upload
      tags = Tag.scan_tags(@upload.tag_string)
      tags = (TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])).compact.uniq.slice(0, 30)
      cookies[:recent_tags] = tags.join(" ")
      cookies[:recent_tags_with_categories] = Tag.categories_for(tags).to_a.flatten.join(" ")
    end
  end

  def upload_params
    permitted_params = %i[
      file source tag_string rating status parent_id artist_commentary_title
      artist_commentary_desc include_artist_commentary referer_url
      md5_confirmation as_pending 
    ]

    params.require(:upload).permit(permitted_params)
  end
end
