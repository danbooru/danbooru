# todo: move this to iqdbs
class IqdbQueriesController < ApplicationController
  before_filter :member_only
  respond_to :html, :json, :xml

  def index
    if !Danbooru.config.iqdbs_server
      raise NotImplementedError.new("the IQDBs service isn't configured. Similarity searches are not available.")
    end

    if params[:url]
      create_by_url
    elsif params[:post_id]
      create_by_post
    else
      render :nothing => true, :status => 422
    end
  end

  # Support both POST /iqdb_queries and GET /iqdb_queries.
  alias_method :create, :index

protected
  def create_by_url
    @download = Iqdb::Download.new(params[:url])
    @download.find_similar
    @results = @download.matches
    respond_with(@results) do |fmt|
      fmt.html { render :layout => false, :action => "create_by_url" }
    end
  end

  def create_by_post
    @post = Post.find(params[:post_id])
    @download = Iqdb::Download.new(@post.complete_preview_file_url)
    @download.find_similar
    @results = @download.matches
    respond_with(@results) do |fmt|
      fmt.js { render :layout => false, :action => "create_by_post" }
    end
  end
end
