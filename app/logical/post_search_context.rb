class PostSearchContext
  extend Memoist
  attr_reader :id, :seq, :tags

  def initialize(params)
    @id = params[:id].to_i
    @seq = params[:seq]
    @tags = params[:q].presence || params[:tags].presence || "status:any"
  end

  def post_id
    if seq == "prev"
      Post.user_tag_match(tags).where("posts.id > ?", id).reorder("posts.id asc").first.try(:id)
    else
      Post.user_tag_match(tags).where("posts.id < ?", id).reorder("posts.id desc").first.try(:id)
    end
  end

  memoize :post_id
end
