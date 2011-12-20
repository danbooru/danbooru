class PopularPostExplorer
  attr_reader :col1, :col2, :posts
  
  def initialize
    load_posts
    sort_posts
  end

private

  def load_posts
    Post.tag_match("order:rank").where("image_width >= ?", Danbooru.config.medium_image_width).limit(5).offset(offset)
  end
  
  def sort_posts
    height1, height2 = 0, 0
    @col1, @col2 = [], []
    
    posts.each do |post|
      if height1 > height2
        @col2 << post
        height2 += post.medium_image_height
      else
        @col1 << post
        height1 += post.medium_image_height
      end
    end
  end
end
