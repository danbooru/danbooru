class PostFlagsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @post_flag = PostFlag.new
    respond_with(@post_flag)
  end

  def index
    @search = PostFlag.order("id desc").search(params[:search])
    @post_flags = @search.paginate(params[:page])
    respond_with(@post_flags) do |format|
      format.xml do
        render :xml => @post_flags.to_xml(:root => "post-flags")
      end
    end
  end

  def create
    @post_flag = PostFlag.create(params[:post_flag].merge(:is_resolved => false))
    respond_with(@post_flag)
  end

private
  def check_privilege(post_flag)
    raise User::PrivilegeError unless (post_flag.creator_id == CurrentUser.id || CurrentUser.is_moderator?)
  end
end
