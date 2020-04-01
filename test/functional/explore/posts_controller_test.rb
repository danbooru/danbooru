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
      end

      context "#curated" do
        should "render" do
          @builder = create(:builder_user)
          @post.add_favorite!(@builder)
          get curated_explore_posts_path
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
    end
  end
end
