# todo: move this to iqdbs
class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    server_check
    if params[:url]
      create_by_url
      respond_with(@results) do |fmt|
        fmt.html { render :layout => false, :action => "create_by_url" }
      end
    elsif params[:post_id]
      create_by_post
      respond_with(@results) do |fmt|
        fmt.js { render :layout => false, :action => "create_by_post" }
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def check
    server_check
    if params[:url].present?
      create_by_url
    elsif params[:post_id].present?
      create_by_post
    else
      @results = []
    end
    respond_with(@results)
  end

  # Support both POST /iqdb_queries and GET /iqdb_queries.
  alias_method :create, :show

protected
  def server_check
    if !Danbooru.config.iqdbs_server
      raise NotImplementedError.new("the IQDBs service isn't configured. Similarity searches are not available.")
    end
  end

  def create_by_url
    @download = Iqdb::Download.new(params[:url])
    @download.find_similar
    @results = @download.matches
  end

  def create_by_post
    @post = Post.find(params[:post_id])
    @download = Iqdb::Download.new(@post.complete_preview_file_url)
    @download.find_similar
    @results = @download.matches
  end
end
