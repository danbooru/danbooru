require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    Favorite # need to force loading the favorite model
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A favorite" do
    should "delete from all tables" do
      user1 = FactoryGirl.create(:user)
      p1 = FactoryGirl.create(:post)

      user1.add_favorite!(p1)
      assert_equal(1, Favorite.count)

      Favorite.destroy_all(:user_id => user1.id, :post_id => p1.id)
      assert_equal(0, Favorite.count)
    end

    should "know which table it belongs to" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      p1 = FactoryGirl.create(:post)
      p2 = FactoryGirl.create(:post)

      user1.add_favorite!(p1)
      user1.add_favorite!(p2)
      user2.add_favorite!(p1)

      favorites = user1.favorites.order("id desc")
      assert_equal(2, favorites.count)
      assert_equal(p2.id, favorites[0].post_id)
      assert_equal(p1.id, favorites[1].post_id)

      favorites = user2.favorites.order("id desc")
      assert_equal(1, favorites.count)
      assert_equal(p1.id, favorites[0].post_id)
    end

    should "not allow duplicates" do
      user1 = FactoryGirl.create(:user)
      p1 = FactoryGirl.create(:post)
      p2 = FactoryGirl.create(:post)
      user1.add_favorite!(p1)
      user1.add_favorite!(p1)

      assert_equal(1, user1.favorites.count)
    end
  end
end
