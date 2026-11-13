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

  # Skips posts the user can't see (banned, taken down, or restricted posts).
  memoize def post_id
    posts = Post.user_tag_match(tags).unscope(:order)

    if seq == "prev"
      posts = posts.where(id: (id + 1)..).find_each(order: :asc, batch_size: 20)
    else
      posts = posts.where(id: ...id).find_each(order: :desc, batch_size: 20)
    end

    posts.find(&:visible?)&.id
  end
end
