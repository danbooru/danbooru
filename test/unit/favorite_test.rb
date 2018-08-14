require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  setup do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @p1 = FactoryBot.create(:post)
    @p2 = FactoryBot.create(:post)

    CurrentUser.user = @user1
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A favorite" do
    should "delete from all tables" do
      @p1.add_favorite!(@user1)
      assert_equal(1, @user1.favorite_count)

      Favorite.where(:user_id => @user1.id, :post_id => @p1.id).delete_all
      assert_equal(0, Favorite.count)
    end

    should "know which table it belongs to" do
      @p1.add_favorite!(@user1)
      @p2.add_favorite!(@user1)
      @p1.add_favorite!(@user2)

      favorites = @user1.favorites.order("id desc")
      assert_equal(2, favorites.count)
      assert_equal(@p2.id, favorites[0].post_id)
      assert_equal(@p1.id, favorites[1].post_id)

      favorites = @user2.favorites.order("id desc")
      assert_equal(1, favorites.count)
      assert_equal(@p1.id, favorites[0].post_id)
    end

    should "not allow duplicates" do
      @p1.add_favorite!(@user1)
      error = assert_raises(Favorite::Error) { @p1.add_favorite!(@user1) }

      assert_equal("You have already favorited this post", error.message)
      assert_equal(1, @user1.favorite_count)
    end

    should "not allow exceeding the user's favorite limit" do
      @user1.stubs(:favorite_limit).returns(0)
      error = assert_raises(Favorite::Error) { @p1.add_favorite!(@user1) }

      assert_equal("You can only keep up to 0 favorites. Upgrade your account to save more.", error.message)
    end
  end
end
