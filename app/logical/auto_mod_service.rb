# whenever a post is approved or rejected, the action is recorded
# in dynamodb (along with some other relevant information at the time)
# for purposes of future data-mining.

class AutoModService
  attr_reader :post

  def initialize(post_or_id)
    if post_or_id.is_a?(Post)
      @post = post_or_id
    else
      @post = Post.find(post_or_id)
    end
  end

  def median_fav_count_for_artist
  end

  def median_fav_count_for_uploader
  end

  def fav_count
  end

  def image_width
  end

  def image_height
  end

  def file_size
  end

  def is_comic
  end

  def is_artist_faved_by_admin
  end

  def rating
  end

  def file_ext
  end
end
