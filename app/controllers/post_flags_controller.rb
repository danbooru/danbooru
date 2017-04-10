class PostFlagsController < ApplicationController
  before_filter :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = PostFlag.new
    respond_with(@post_flag)
  end

  def index
    @post_flags = PostFlag.search(params[:search]).includes(:creator, post: [:flags, :uploader, :approver])
    @post_flags = @post_flags.paginate(params[:page], limit: params[:limit])
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

  def show
    @post_flag = PostFlag.find(params[:id])
    respond_with(@post_flag)
  end

private
  def check_privilege(post_flag)
    raise User::PrivilegeError unless (post_flag.creator_id == CurrentUser.id || CurrentUser.is_moderator?)
  end
end
