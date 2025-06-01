# frozen_string_literal: true

class PostFlagsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_flag = authorize PostFlag.new(permitted_attributes(PostFlag))
    respond_with(@post_flag)
  end

  def index
    @post_flags = authorize PostFlag.paginated_search(params)

    if request.format.html?
      @post_flags = @post_flags.includes(:creator, post: [:flags, :uploader, :approver, :media_asset])
    else
      @post_flags = @post_flags.includes(:post)
    end

    respond_with(@post_flags)
  end

  def create
    @post_flag = authorize PostFlag.new(creator: CurrentUser.user, **permitted_attributes(PostFlag))
    @post_flag.save

    respond_with(@post_flag, notice: "Post flagged")
  end

  def show
    @post_flag = authorize PostFlag.find(params[:id])
    respond_with(@post_flag) do |fmt|
      fmt.html { redirect_to post_flags_path(search: { id: @post_flag.id }) }
    end
  end

  def edit
    @post_flag = authorize PostFlag.find(params[:id])
    respond_with(@post_flag)
  end

  def update
    @post_flag = authorize PostFlag.find(params[:id])
    @post_flag.update(permitted_attributes(@post_flag))

    respond_with(@post_flag, location: @post_flag.post)
  end
end
