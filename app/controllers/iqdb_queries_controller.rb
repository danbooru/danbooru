# todo: move this to iqdbs
class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    @results = find_similar

    respond_with(@results) do |fmt|
      fmt.html { render :layout => false, :action => "create_by_url" }
      fmt.js { render :layout => false, :action => "create_by_post" }
    end
  end

  def check
    @results = find_similar
    respond_with(@results)
  end

  # Support both POST /iqdb_queries and GET /iqdb_queries.
  alias_method :create, :show

protected
  def find_similar
    return [] if params[:url].blank? && params[:post_id].blank?

    params[:url] = Post.find(params[:post_id]).preview_file_url if params[:post_id].present?
    Iqdb::Download.find_similar(params[:url])
  end
end
