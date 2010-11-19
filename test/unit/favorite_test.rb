require_relative '../test_helper'

class FavoriteTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A favorite" do
    should "know which table it belongs to" do
      user1 = Factory.create(:user)
      user2 = Factory.create(:user)      
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
    
      p1.add_favorite(user1)
      p2.add_favorite(user1)
      p1.add_favorite(user2)
    
      favorites = user1.favorite_posts
      assert_equal(2, favorites.size)
      assert_equal(p2.id, favorites[0].id)
      assert_equal(p1.id, favorites[1].id)
      
      favorites = user2.favorite_posts
      assert_equal(1, favorites.size)
      assert_equal(p1.id, favorites[0].id)
    end
    
    should "filter before a given id" do
      user1 = Factory.create(:user)
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      p3 = Factory.create(:post)
      p1.add_favorite(user1)
      p2.add_favorite(user1)
      p3.add_favorite(user1)
      favorites = user1.favorite_posts
      favorites = user1.favorite_posts(:before_id => favorites.first.favorite_id)
      assert_equal(2, favorites.count)
      assert_equal(p2.id, favorites[0].id)
      assert_equal(p1.id, favorites[1].id)
    end
  end
end
