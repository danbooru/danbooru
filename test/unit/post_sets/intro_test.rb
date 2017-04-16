require 'test_helper'
require "danbooru/paginator/pagination_error"

module PostSets
  class IntroTest < ActiveSupport::TestCase
    context "In all cases" do
      setup do
        @user = FactoryGirl.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"

        @post_1 = FactoryGirl.create(:post, :tag_string => "a")
        @post_2 = FactoryGirl.create(:post, :tag_string => "b")
        @post_3 = FactoryGirl.create(:post, :tag_string => "c")
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      context "a set for the 'a' tag query" do
        setup do
          @post_4 = FactoryGirl.create(:post, :tag_string => "a", :fav_count => 5)
          @post_5 = FactoryGirl.create(:post, :tag_string => "a", :fav_count => 5)
        end

        context "with no page" do
          setup do
            @set = PostSets::Intro.new("a")
            ::Post.stubs(:records_per_page).returns(1)
          end

          should "return the first element" do
            assert_equal(@post_5.id, @set.posts.first.id)
          end
        end
      end
    end
  end
end
