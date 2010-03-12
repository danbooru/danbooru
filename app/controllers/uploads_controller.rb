class UploadsController < ApplicationController
  def new
    @upload = Upload.new
    if params[:url]
      @post = Post.find_by_source(params[:url])
    end
  end
  
  def show
  end

  def create
    unless @current_user.can_upload?
      respond_to_error("Daily limit exceeded", {:controller => "user", :action => "upload_limit"}, :status => 421)
      return
    end

    if @current_user.is_contributor_or_higher?
      status = "active"
    else
      status = "pending"
    end

		begin
    	@post = Post.new(params[:post].merge(:updater_user_id => @current_user.id, :updater_ip_addr => request.remote_ip))
    	@post.user_id = @current_user.id
    	@post.status = status
    	@post.ip_addr = request.remote_ip
    	@post.save
		rescue Errno::ENOENT
			respond_to_error("Internal error. Try uploading again.", {:controller => "post", :action => "error"})
			return
		end

    if @post.errors.empty?
      if params[:md5] && @post.md5 != params[:md5].downcase
        @post.destroy
        respond_to_error("MD5 mismatch", {:action => "error"}, :status => 420)
      else
        respond_to_success("Post uploaded", {:controller => "post", :action => "show", :id => @post.id, :tag_title => @post.tag_title}, :api => {:post_id => @post.id, :location => url_for(:controller => "post", :action => "show", :id => @post.id)})
      end
    elsif @post.errors.invalid?(:md5)
      p = Post.find_by_md5(@post.md5)

      update = { :tags => p.cached_tags + " " + params[:post][:tags], :updater_user_id => session[:user_id], :updater_ip_addr => request.remote_ip }
      update[:source] = @post.source if p.source.blank? && !@post.source.blank?
      p.update_attributes(update)

      respond_to_error("Post already exists", {:controller => "post", :action => "show", :id => p.id, :tag_title => @post.tag_title}, :api => {:location => url_for(:controller => "post", :action => "show", :id => p.id)}, :status => 423)
    else
      respond_to_error(@post, :action => "error")
    end
  end
end
