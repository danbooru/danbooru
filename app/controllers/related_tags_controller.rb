class RelatedTagsController < ApplicationController
  respond_to :json

  def show
    @query = RelatedTagQuery.new(params[:query].to_s.downcase, params[:category])
    respond_with(@query) do |format|
      format.json do
        render :json => @query.to_json
      end
    end
  end

  def update
    render(text: "forbidden", status: 403) && return false unless params[:key] == Danbooru.config.shared_remote_key

    @tag = Tag.find_by_name(params[:name])
    @tag.related_tags = params[:related_tags].scan(/\S+/).in_groups_of(2)
    @tag.related_tags_updated_at = Time.now
    @tag.save

    render nothing: true
  end
end
