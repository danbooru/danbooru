class PostAppealsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = PostAppeal.new(post_appeal_params)
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = PostAppeal.paginated_search(params).includes(model_includes(params))
    respond_with(@post_appeals)
  end

  def create
    @post_appeal = PostAppeal.create(post_appeal_params.merge(creator: CurrentUser.user))
    respond_with(@post_appeal)
  end

  def show
    @post_appeal = PostAppeal.find(params[:id])
    respond_with(@post_appeal) do |fmt|
      fmt.html { redirect_to post_appeals_path(search: { id: @post_appeal.id }) }
    end
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [:post]
    else
      [:creator, {post: [:appeals, :uploader, :approver]}]
    end
  end

  def post_appeal_params
    params.fetch(:post_appeal, {}).permit(%i[post_id reason])
  end
end
