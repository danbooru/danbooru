class PostAppealsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = PostAppeal.new
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = PostAppeal.includes(:creator).search(search_params).includes(post: [:appeals, :uploader, :approver])
    @post_appeals = @post_appeals.paginate(params[:page], limit: params[:limit])
    respond_with(@post_appeals) do |format|
      format.xml do
        render :xml => @post_appeals.to_xml(:root => "post-appeals")
      end
    end
  end

  def create
    @post_appeal = PostAppeal.create(post_appeal_params)
    respond_with(@post_appeal)
  end

  def show
    @post_appeal = PostAppeal.find(params[:id])
    respond_with(@post_appeal)
  end

  private

  def post_appeal_params
    params.fetch(:post_appeal, {}).permit(%i[post_id reason])
  end
end
