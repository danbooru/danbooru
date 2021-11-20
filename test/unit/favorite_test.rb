require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  setup do
    @user1 = create(:user)
    @user2 = create(:user)
    @p1 = create(:post)
    @p2 = create(:post)
  end

  context "Favorites: " do
    context "removing a favorite" do
      should "update the post and user favorite counts" do
        @user1 = create(:restricted_user)
        fav = Favorite.create!(post: @p1, user: @user1)

        assert_equal(1, @user1.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(0, @p1.reload.score)
        refute(PostVote.positive.exists?(post: @p1, user: @user))

        Favorite.destroy_by(post: @p1, user: @user1)

        assert_equal(0, @user1.reload.favorite_count)
        assert_equal(0, @p1.reload.fav_count)
      end

      should "remove the upvote if the user could vote" do
        @user = create(:gold_user)
        @vote = create(:post_vote, post: @p1, user: @user, score: 1)
        fav = Favorite.create!(post: @p1, user: @user)

        assert_equal(1, @user.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(1, @p1.reload.score)
        assert(PostVote.positive.exists?(post: @p1, user: @user))

        Favorite.destroy_by(post: @p1, user: @user)

        assert_equal(0, @user.reload.favorite_count)
        assert_equal(0, @p1.reload.fav_count)
        assert_equal(0, @p1.reload.score)
        refute(PostVote.positive.exists?(post: @p1, user: @user))
      end
    end

    context "adding a favorite" do
      should "not upvote the post if the user can't vote" do
        @user1 = create(:restricted_user)
        Favorite.create!(post: @p1, user: @user1)

        assert_equal(1, @user1.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(0, @p1.reload.score)
        refute(PostVote.positive.exists?(post: @p1, user: @user1))
      end

      should "upvote the post if the user can vote" do
        @user = create(:gold_user)
        Favorite.create!(post: @p1, user: @user)

        assert_equal(1, @user.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(1, @p1.reload.score)
        assert(PostVote.positive.exists?(post: @p1, user: @user))
      end

      should "convert a downvote into an upvote if the post was downvoted" do
        @user = create(:gold_user)
        @vote = create(:post_vote, post: @p1, user: @user, score: -1)

        assert_equal(-1, @p1.reload.score)
        Favorite.create!(post: @p1, user: @user)

        assert_equal(1, @user.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(1, @p1.reload.score)
        assert(PostVote.positive.exists?(post: @p1, user: @user))
        refute(PostVote.negative.exists?(post: @p1, user: @user))
      end

      should "not allow duplicate favorites" do
        @f1 = Favorite.create(post: @p1, user: @user1)
        @f2 = Favorite.create(post: @p1, user: @user1)

        assert_equal(["You have already favorited this post"], @f2.errors.full_messages)
        assert_equal(1, @user1.reload.favorite_count)
        assert_equal(1, @p1.reload.fav_count)
        assert_equal(1, @p1.reload.score)
      end
    end
  end
end
