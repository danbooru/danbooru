class IqdbQueriesController < ApplicationController
  respond_to :html, :json
  before_action :detect_xhr

  def show
    if params[:url]
      strategy = Sources::Strategies.find(params[:url])
      @matches = IqdbProxy.query(strategy.image_url)
    end

    if params[:post_id]
      @matches = IqdbProxy.query(Post.find(params[:post_id]).preview_file_url)
    end

    if params[:matches]
      @matches = IqdbProxy.decorate_posts(JSON.parse(params[:matches]))
    end

    respond_with(@matches) do |fmt|
      fmt.html do |html|
        html.xhr { render layout: false}
      end
      
      fmt.json do
        render json: @matches
      end
    end
  end

private
  
  def detect_xhr
    if request.xhr?
      request.variant = :xhr
    end
  end
end
