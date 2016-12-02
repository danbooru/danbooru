# todo: move this to iqdbs
class IqdbQueriesController < ApplicationController
  before_filter :member_only

  def create
    if !Danbooru.config.iqdbs_server
      render :nothing => true
      return
    end

    if params[:url]
      create_by_url
    elsif params[:post_id]
      create_by_post
    else
      render :nothing => true, :status => 422
    end
  end

protected
  def create_by_url
    @download = Iqdb::Download.new(params[:url])
    @download.find_similar
    @results = @download.matches
    render :layout => false, :action => "create_by_url"
  end

  def create_by_post
    @post = Post.find(params[:post_id])
    @download = Iqdb::Download.new(@post.complete_preview_file_url)
    @download.find_similar
    @results = @download.matches
    render :layout => false, :action => "create_by_post"
  end
end