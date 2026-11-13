# frozen_string_literal: true

# A PostSearchContext handles navigating to the next or previous post in a
# search. This is used in the search navbar above or below posts.
#
# @see PostNavbarComponent
# @see PostsController#show_seq
class PostSearchContext
  extend Memoist

  attr_reader :id, :seq, :tags

  def initialize(params)
    @id = params[:id].to_i
    @seq = params[:seq]
    @tags = params[:q].presence || params[:tags].presence || "status:any"
  end

  # Skips posts the user can't see (banned, taken down, or restricted posts). Only checks the next 20 posts to bound
  # the cost; if none of them are visible, returns the adjacent post.
  memoize def post_id
    posts = Post.user_tag_match(tags)

    if seq == "prev"
      posts = posts.where(id: (id + 1)..).reorder("posts.id asc").limit(20).to_a
    else
      posts = posts.where(id: ...id).reorder("posts.id desc").limit(20).to_a
    end

    (posts.find(&:visible?) || posts.first)&.id
  end
end
