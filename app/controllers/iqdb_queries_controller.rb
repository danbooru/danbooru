class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml, :js

  def show
    if params[:url]
      url = Sources::Strategies.find(params[:url]).image_url
      @matches = IqdbProxy.query(url, params[:limit], params[:similarity])
    elsif params[:post_id]
      url = Post.find(params[:post_id]).preview_file_url
      @matches = IqdbProxy.query(url, params[:limit], params[:similarity])
    elsif params[:matches]
      @matches = IqdbProxy.decorate_posts(JSON.parse(params[:matches]))
    end

    respond_with(@matches)
  end
end
