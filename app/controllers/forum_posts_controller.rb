class ForumPostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @forum_post = ForumPost.new_reply(params)
    respond_with(@forum_post)
  end
  
  def edit
    @forum_post = ForumPost.find(params[:id])
    check_privilege(@forum_post)
    respond_with(@forum_post)
  end
  
  def index
    @search = ForumPost.search(params[:search])
    @forum_posts = @search.paginate(:page => params[:page], :order => "id DESC")
    respond_with(@forum_posts)
  end
  
  def search
    @search = ForumPost.search(params[:search])
  end

  def show
    @forum_post = ForumPost.find(params[:id])
    respond_with(@forum_post)
  end
  
  def create
    @forum_post = ForumPost.create(params[:forum_post])
    respond_with(@forum_post, :location => forum_topic_path(@forum_post.topic, :page => @forum_post.topic.last_page))
  end
  
  def update
    @forum_post = ForumPost.find(params[:id])
    check_privilege(@forum_post)
    @forum_post.update_attributes(params[:forum_post])
    respond_with(@forum_post, :location => forum_topic_path(@forum_post.topic, :page => @forum_post.topic.last_page))
  end
  
  def destroy
    @forum_post = ForumPost.find(params[:id])
    check_privilege(@forum_post)
    @forum_post.destroy
    respond_with(@forum_post)
  end

private
  def check_privilege(forum_post)
    if !forum_post.editable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
  end
end
