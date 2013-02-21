class PostAppealsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @post_appeal = PostAppeal.new
    respond_with(@post_appeal)
  end
  
  def index
    @search = PostAppeal.search(params[:search]).order("id desc")
    @post_appeals = @search.paginate(params[:page])
  end
  
  def create
    @post_appeal = PostAppeal.create(params[:post_appeal])
    respond_with(@post_appeal)
  end

private
  def check_privilege(post_appeal)
    raise User::PrivilegeError unless (post_appeal.creator_id == CurrentUser.id || CurrentUser.is_moderator?)
  end
end
