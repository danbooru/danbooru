class PostModerationDetail < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  
  def self.filter(posts, user, select_hidden = false)
    hidden = where(:user_id => user.id).select("post_id").map(&:post_id)
    if select_hidden
      posts.select {|x| hidden.include?(x.id)}
    else
      posts.reject {|x| hidden.include?(x.id)}
    end
  end
  
  def self.prune!
    joins(:post).where("posts.is_pending = FALSE AND posts.is_flagged = FALSE").each do |hidden_post|
      hidden_post.destroy
    end
  end
end
