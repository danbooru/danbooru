class PostSearchContext
  attr_reader :params, :post_id

  def initialize(params)
    @params = params
    raise unless params[:seq].present?
    raise unless params[:id].present?

    @post_id = find_post_id
  end

  def find_post_id
    if params[:seq] == "prev"
      post = Post.tag_match(params[:tags]).where("posts.id > ?", params[:id].to_i).reorder("posts.id asc").first
    else
      post = Post.tag_match(params[:tags]).where("posts.id < ?", params[:id].to_i).reorder("posts.id desc").first
    end

    if post
      post.id
    else
      nil
    end
  end
end
