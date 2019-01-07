class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html, except: [:update]
  before_action :require_reportbooru_key, only: [:update]

  def show
    @query = RelatedTagQuery.new(query: params[:query], category: params[:category], user: CurrentUser.user)
    respond_with(@query)
  end

  def update
    @tag = Tag.find_by_name(params[:name])
    @tag.related_tags = params[:related_tags]
    @tag.related_tags_updated_at = Time.now
    @tag.post_count = params[:post_count] if params[:post_count].present?
    @tag.save
    head :ok
  end

  protected

  def require_reportbooru_key
    unless Danbooru.config.reportbooru_key.present? && params[:key] == Danbooru.config.reportbooru_key
      raise User::PrivilegeError
    end
  end
end
