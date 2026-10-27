require "test_helper"

module Explore
  class PostsControllerTest < ActionDispatch::IntegrationTest
    context "in all cases" do
      setup do
        @post = create(:post)
      end

      context "#popular" do
        should "render" do
          get popular_explore_posts_path
          assert_response :success
        end

        should "work with a blank date" do
          get popular_explore_posts_path(date: "")
          assert_response :success
        end

        context "the limit param" do
          setup do
            create(:post)
            @user = create(:user, per_page: 2)
          end

          should "use the user's per page setting by default" do
            get_auth popular_explore_posts_path, @user, as: :json
            assert_equal(2, response.parsed_body.size)
          end

          should "use the limit param" do
            get_auth popular_explore_posts_path(limit: 1), @user, as: :json
            assert_equal(1, response.parsed_body.size)
          end

          should "use the user's per page setting for a blank limit param" do
            get_auth popular_explore_posts_path(limit: ""), @user, as: :json
            assert_equal(2, response.parsed_body.size)
          end
        end
      end

      context "#viewed" do
        should "render" do
          mock_post_view_rankings(Date.today, [[@post.id, 100]])
          get viewed_explore_posts_path
          assert_response :success
        end
      end

      context "#searches" do
        should "render" do
          mock_post_search_rankings(Date.today, [["1girl", 100], ["original", 50]])
          get searches_explore_posts_path
          assert_response :success
          assert_select "tbody tr", count: 2
        end
      end

      context "#missed_searches" do
        should "render" do
          mock_missed_search_rankings([["1girl", 100], ["original", 50]])
          get missed_searches_explore_posts_path
          assert_response :success
          assert_select "tbody tr", count: 2
        end
      end
    end
  end
end
