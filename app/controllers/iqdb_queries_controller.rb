class IqdbQueriesController < ApplicationController
  respond_to :html, :json

  def show
    if params[:url]
      url = URI.parse(Danbooru.config.iqdbs_server)
      url.path = "/similar"
      url.query = {callback: iqdb_queries_url(format: params[:format]), url: params[:url]}.to_query
      redirect_to url.to_s
      return
    end

    if params[:post_id]
      post = Post.find(params[:post_id])
      url = URI.parse(Danbooru.config.iqdbs_server)
      url.path = "/similar"
      url.query = {callback: iqdb_queries_url(format: params[:format]), url: post.preview_file_url}.to_query
      redirect_to url.to_s
      return      
    end

    if params[:matches]
      @matches = JSON.parse(params[:matches])
      @matches = @matches.map {|x| [Post.find(x[0]), x[1]]}
    end

    respond_with(@matches)
  end
end
