class Favorite < ActiveRecord::Base
  belongs_to :post
  scope :for_user, lambda {|user_id| where("user_id % 100 = #{user_id.to_i % 100} and user_id = #{user_id.to_i}")}
  attr_accessible :user_id, :post_id

  # this is necessary because there's no trigger for deleting favorites
  def self.destroy_all(hash)
    if hash[:user_id] && hash[:post_id]
      connection.execute("delete from favorites_#{hash[:user_id] % 100} where user_id = #{hash[:user_id]} and post_id = #{hash[:post_id]}")
    elsif hash[:user_id]
      connection.execute("delete from favorites_#{hash[:user_id] % 100} where user_id = #{hash[:user_id]}")
    end
  end

  def self.add(post, user)
    Favorite.transaction do
      return if Favorite.for_user(user.id).where(:user_id => user.id, :post_id => post.id).exists?
      Favorite.create!(:user_id => user.id, :post_id => post.id)
      Post.where(:id => post.id).update_all("fav_count = fav_count + 1")
      Post.where(:id => post.id).update_all("score = score + 1") if user.is_gold?
      post.append_user_to_fav_string(user.id)
      User.where(:id => user.id).update_all("favorite_count = favorite_count + 1")
      user.favorite_count += 1
      # post.fav_count += 1 # this is handled in Post#clean_fav_string!
      post.score += 1 if user.is_gold?
    end
  end

  def self.remove(post, user)
    Favorite.transaction do
      return unless Favorite.for_user(user.id).where(:user_id => user.id, :post_id => post.id).exists?
      Favorite.destroy_all(:user_id => user.id, :post_id => post.id)
      Post.where(:id => post.id).update_all("fav_count = fav_count - 1")
      Post.where(:id => post.id).update_all("Score = score - 1") if user.is_gold?
      post.delete_user_from_fav_string(user.id)
      User.where(:id => user.id).update_all("favorite_count = favorite_count - 1")
      user.favorite_count -= 1
      post.fav_count -= 1
      post.score -= 1 if user.is_gold?
    end
  end
end
