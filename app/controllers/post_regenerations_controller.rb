class PostRegenerationsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create
    @post_regeneration = authorize PostRegeneration.new(creator: CurrentUser.user, **permitted_attributes(PostRegeneration))
    @post_regeneration.execute_category_action!
    @post_regeneration.save

    respond_with(@post_regeneration, location: @post_regeneration.post)
  end

  def index
    @post_regenerations = authorize PostRegeneration.paginated_search(params)
    @post_regenerations = @post_regenerations.includes(:creator, :post) if request.format.html?

    respond_with(@post_regenerations)
  end
end
