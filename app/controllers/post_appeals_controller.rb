class PostAppealsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = PostAppeal.new(post_appeal_params)
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = PostAppeal.includes(:creator).paginated_search(params).includes(post: [:appeals, :uploader, :approver])
    respond_with(@post_appeals)
  end

  def create
    @post_appeal = PostAppeal.create(post_appeal_params)
    respond_with(@post_appeal)
  end

  def show
    @post_appeal = PostAppeal.find(params[:id])
    respond_with(@post_appeal) do |fmt|
      fmt.html { redirect_to post_appeals_path(search: { id: @post_appeal.id }) }
    end
  end

  private

  def post_appeal_params
    params.fetch(:post_appeal, {}).permit(%i[post_id reason])
  end
end
