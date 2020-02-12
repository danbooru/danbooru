class PostFlagsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = PostFlag.new(post_flag_params)
    respond_with(@post_flag)
  end

  def index
    @post_flags = PostFlag.paginated_search(params).includes(model_includes(params))
    respond_with(@post_flags)
  end

  def create
    @post_flag = PostFlag.create(post_flag_params.merge(creator: CurrentUser.user))
    respond_with(@post_flag)
  end

  def show
    @post_flag = PostFlag.find(params[:id])
    respond_with(@post_flag) do |fmt|
      fmt.html { redirect_to post_flags_path(search: { id: @post_flag.id }) }
    end
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [:post]
    else
      includes_array = [{post: [:flags, :uploader, :approver]}]
      includes_array << :creator if CurrentUser.is_moderator?
      includes_array
    end
  end

  def post_flag_params
    params.fetch(:post_flag, {}).permit(%i[post_id reason])
  end
end
