class IqdbQueriesController < ApplicationController
  before_filter :member_only

  def create
    if !Danbooru.config.iqdb_hostname_and_port
      render :nothing => true
      return
    end

    if params[:url]
      create_by_url
    elsif params[:post_id]
      create_by_post
    end
  end

protected
  def create_by_url
    @download = Iqdb::Download.new(params[:url])
    @download.download_from_source
    @download.find_similar
    render :layout => false, :action => "create_by_url"
  end

  def create_by_post
    @post = Post.find(params[:post_id])
    @results = Iqdb::Server.default.similar(@post.id, 3)
    render :layout => false, :action => "create_by_post"
  end
end