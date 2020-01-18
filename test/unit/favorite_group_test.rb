require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  def setup
    @fav_group = create(:favorite_group)
  end

  context "searching by post id" do
    should "return the fav group" do
      posts = create_list(:post, 3)

      @fav_group.add!(posts[0])
      assert_equal(@fav_group.id, FavoriteGroup.for_post(posts[0].id).first.id)

      @fav_group.add!(posts[1])
      assert_equal(@fav_group.id, FavoriteGroup.for_post(posts[1].id).first.id)

      @fav_group.add!(posts[2])
      assert_equal(@fav_group.id, FavoriteGroup.for_post(posts[2].id).first.id)
    end
  end

  context "expunging a post" do
    should "remove it from all favorite groups" do
      @post = FactoryBot.create(:post)

      @fav_group.add!(@post)
      assert_equal([@post.id], @fav_group.post_ids)

      @post.expunge!
      assert_equal([], @fav_group.reload.post_ids)
    end
  end

  context "adding a post to a favgroup" do
    should "not allow adding duplicate posts" do
      post = create(:post)

      @fav_group.add!(post)
      assert(@fav_group.valid?)
      assert_equal([post.id], @fav_group.reload.post_ids)

      assert_raise(ActiveRecord::RecordInvalid) { @fav_group.add!(post) }
      assert_equal([post.id], @fav_group.reload.post_ids)

      @fav_group.reload.update(post_ids: [post.id, post.id])
      refute(@fav_group.valid?)
      assert_equal([post.id], @fav_group.reload.post_ids)
    end

    should "not allow adding nonexistent posts" do
      @fav_group.update(post_ids: [0])

      refute(@fav_group.valid?)
      assert_equal([], @fav_group.reload.post_ids)
    end
  end
end
