require "test_helper"

class RecommendedPostsControllerTest < ActionDispatch::IntegrationTest
  context "The recommended posts controller" do
    setup do
      @user = travel_to(1.month.ago) {create(:user)}
      @post = as(@user) { create(:post, tag_string: "aaaa") }
      RecommenderService.stubs(:enabled?).returns(true)
    end

    context "post context" do
      setup do
        RecommenderService.stubs(:available_for_post?).returns(true)
        RecommenderService.stubs(:recommend_for_post).returns([{ post: @post, score: 1.0 }])
      end

      should "render" do
        get_auth recommended_posts_path(search: { post_id: @post.id }), @user
        assert_response :success
        assert_select ".recommended-posts"
        assert_select ".recommended-posts #post_#{@post.id}"
      end
    end

    context "user context" do
      setup do
        RecommenderService.stubs(:available_for_user?).returns(true)
        RecommenderService.stubs(:recommend_for_user).returns([{ post: @post, score: 1.0 }])
      end

      should "render" do
        get_auth recommended_posts_path(search: { user_id: @user.id }), @user
        assert_response :success
        assert_select ".recommended-posts"
        assert_select ".recommended-posts #post_#{@post.id}"
      end

      should "not show recommendations for users with private favorites to other users" do
        @other_user = create(:user, enable_private_favorites: true)
        get_auth recommended_posts_path(search: { user_id: @other_user.id }), @user
        assert_response 403
      end
    end
  end
end
