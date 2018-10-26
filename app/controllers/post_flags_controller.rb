class PostFlagsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = PostFlag.new(post_flag_params)
    respond_with(@post_flag)
  end

  def index
    @post_flags = PostFlag.search(search_params).includes(:creator, post: [:flags, :uploader, :approver])
    @post_flags = @post_flags.paginate(params[:page], limit: params[:limit])
    respond_with(@post_flags) do |format|
      format.xml do
        render :xml => @post_flags.to_xml(:root => "post-flags")
      end
    end
  end

  def create
    @post_flag = PostFlag.create(post_flag_params)
    respond_with(@post_flag)
  end

  def show
    @post_flag = PostFlag.find(params[:id])
    respond_with(@post_flag) do |fmt|
      fmt.html { redirect_to post_flags_path(search: { id: @post_flag.id }) }
    end
  end

  private

  def post_flag_params
    params.fetch(:post_flag, {}).permit(%i[post_id reason])
  end
end
