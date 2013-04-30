class Favorite < ActiveRecord::Base
  belongs_to :post
  scope :for_user, lambda {|user_id| where("user_id % 100 = #{user_id.to_i % 100} and user_id = #{user_id.to_i}")}

  # this is necessary because there's no trigger for deleting favorites
  def self.destroy_all(hash)
    if hash[:user_id] && hash[:post_id]
      connection.execute("delete from favorites_#{hash[:user_id] % 100} where user_id = #{hash[:user_id]} and post_id = #{hash[:post_id]}")
    elsif hash[:user_id]
      connection.execute("delete from favorites_#{hash[:user_id] % 100} where user_id = #{hash[:user_id]}")
    end
  end

  def self.add(post, user)
    return if Favorite.for_user(user.id).exists?(:user_id => user.id, :post_id => post.id)
    Favorite.create(:user_id => user.id, :post_id => post.id)
    Post.update_all("fav_count = fav_count + 1", "id = #{post.id}")
    Post.update_all("score = score + 1", "id = #{post.id}") if user.is_gold?
    post.append_user_to_fav_string(user.id)
    user.add_favorite!(post)
    user.increment!(:favorite_count)
    post.add_favorite!(user)
  end

  def self.remove(post, user)
    return unless Favorite.for_user(user.id).exists?(:user_id => user.id, :post_id => post.id)
    Favorite.destroy_all(:user_id => user.id, :post_id => post.id)
    Post.update_all("fav_count = fav_count - 1", "id = #{post.id}")
    Post.update_all("score = score - 1", "id = #{post.id}") if user.is_gold?
    post.delete_user_from_fav_string(user.id)
    user.remove_favorite!(post)
    user.decrement!(:favorite_count)
    post.remove_favorite!(user)
  end
end
