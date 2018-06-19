class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml

  def show
    if params[:url]
      url = URI::HTTP.build(host: Danbooru.config.iqdbs_server, path: "/similar", query: URI.encode_www_form({callback: iqdb_queries_url, url: params[:url]}))
      redirect_to url.to_s
      return
    end

    if params[:post_id]
      post = Post.find(params[:post_id])
      url = URI::HTTP.build(host: Danbooru.config.iqdbs_server, path: "/similar", query: URI.encode_www_form({callback: iqdb_queries_url, url: post.preview_file_url}))
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
