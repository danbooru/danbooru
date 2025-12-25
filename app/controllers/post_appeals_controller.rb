# frozen_string_literal: true

class PostAppealsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_appeal = authorize PostAppeal.new(permitted_attributes(PostAppeal))
    respond_with(@post_appeal)
  end

  def index
    @post_appeals = authorize PostAppeal.paginated_search(params)

    if request.format.html?
      @post_appeals = @post_appeals.includes(:creator, post: [:appeals, :uploader, :approver, :media_asset])
    else
      @post_appeals = @post_appeals.includes(:post)
    end

    respond_with(@post_appeals)
  end

  def create
    @post_appeal = authorize PostAppeal.new(creator: CurrentUser.user, **permitted_attributes(PostAppeal))
    @post_appeal.save

    respond_with(@post_appeal, notice: "Post appealed")
  end

  def show
    @post_appeal = authorize PostAppeal.find(params[:id])
    respond_with(@post_appeal) do |fmt|
      fmt.html { redirect_to post_appeals_path(search: { id: @post_appeal.id }) }
    end
  end

  def edit
    @post_appeal = authorize PostAppeal.find(params[:id])
    respond_with(@post_appeal)
  end

  def update
    @post_appeal = authorize PostAppeal.find(params[:id])
    @post_appeal.update(permitted_attributes(@post_appeal))

    respond_with(@post_appeal, location: @post_appeal.post)
  end
end
