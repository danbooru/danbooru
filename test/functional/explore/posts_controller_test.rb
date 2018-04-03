require "test_helper"

module Explore
  class PostsControllerTest < ActionDispatch::IntegrationTest
    context "in all cases" do
      setup do
        @user = create(:user)
        as_user do
          create(:post)
        end
      end

      context "#popular" do
        should "render" do
          get popular_explore_posts_path
          assert_response :success
        end
      end

      context "#searches" do
        should "render" do
          get searches_explore_posts_path
          assert_response :success
        end
      end

      context "#missed_searches" do
        should "render" do
          get missed_searches_explore_posts_path
          assert_response :success
        end
      end

      context "#intro" do
        should "render" do
          get intro_explore_posts_path
          assert_response :success
        end
      end
    end
  end
end
