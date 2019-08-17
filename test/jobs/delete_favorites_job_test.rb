require 'test_helper'

class DeleteFavoritesJobTest < ActiveJob::TestCase
  context "DeleteFavoritesJob" do
    should "delete all favorites" do
      user = create(:user)
      posts = create_list(:post, 3)
      favorites = posts.each { |post| post.add_favorite!(user) }

      assert_equal(3, user.favorite_count)
      assert_equal(3, user.favorites.count)
      assert_equal(3, Post.raw_tag_match("fav:#{user.id}").count)

      DeleteFavoritesJob.perform_now(user)

      assert_equal(0, user.reload.favorite_count)
      assert_equal(0, user.favorites.count)
      assert_equal(0, Post.raw_tag_match("fav:#{user.id}").count)
    end
  end
end
