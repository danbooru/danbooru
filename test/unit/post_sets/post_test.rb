require 'test_helper'
require "danbooru/paginator/pagination_error"

module PostSets
  class PostTest < ActiveSupport::TestCase
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

      context "a set for page 2" do
        setup do
          @set = PostSets::Post.new("", 2)
          ::Post.stubs(:records_per_page).returns(1)
        end

        should "return the second element" do
          assert_equal(@post_2.id, @set.posts.first.id)
        end
      end

      context "a set for the 'a' tag query" do
        setup do
          @post_4 = FactoryGirl.create(:post, :tag_string => "a")
          @post_5 = FactoryGirl.create(:post, :tag_string => "a")
        end

        context "with no page" do
          setup do
            @set = PostSets::Post.new("a")
            ::Post.stubs(:records_per_page).returns(1)
          end

          should "return the first element" do
            assert_equal(@post_5.id, @set.posts.first.id)
          end
        end

        context "for before the first element" do
          setup do
            @set = PostSets::Post.new("a", "b#{@post_5.id}")
            ::Post.stubs(:records_per_page).returns(1)
          end

          should "return the second element" do
            assert_equal(@post_4.id, @set.posts.first.id)
          end
        end

        context "for after the second element" do
          setup do
            @set = PostSets::Post.new("a", "a#{@post_4.id}")
            @set.stubs(:records_per_page).returns(1)
          end

          should "return the first element" do
            assert_equal(@post_5.id, @set.posts.first.id)
          end
        end
      end

      context "a set for the 'a b' tag query" do
        setup do
          @set = PostSets::Post.new("a b")
        end

        should "know it isn't a single tag" do
          assert(!@set.is_single_tag?)
        end
      end

      context "a set going to the 1,001st page" do
        setup do
          @set = PostSets::Post.new("a", 1_001)
        end

        should "fail" do
          assert_raises(Danbooru::Paginator::PaginationError) do
            @set.posts
          end
        end
      end

      context "a set for the 'a b c' tag query" do
        setup do
          @set = PostSets::Post.new("a b c")
        end

        context "for a non-gold user" do
          should "fail" do
            assert_raises(::Post::SearchError) do
              @set.posts
            end
          end
        end

        context "for a gold user" do
          setup do
            CurrentUser.user = FactoryGirl.create(:gold_user)
          end

          should "pass" do
            assert_nothing_raised do
              @set.posts
            end
          end
        end
      end

      context "a set for the 'a' tag query" do
        setup do
          @set = PostSets::Post.new("a")
        end

        should "know it is a single tag" do
          assert(@set.is_single_tag?)
        end

        should "normalize its tag query" do
          assert_equal("a", @set.tag_string)
        end

        should "know the count" do
          assert_equal(1, @set.posts.total_count)
        end

        should "find the posts" do
          assert_equal(@post_1.id, @set.posts.first.id)
        end

        context "that has a matching wiki page" do
          setup do
            @wiki_page = FactoryGirl.create(:wiki_page, :title => "a")
          end

          should "find the wiki page" do
            assert_not_nil(@set.wiki_page)
            assert_equal(@wiki_page.id, @set.wiki_page.id)
          end
        end

        context "that has a matching artist" do
          setup do
            @artist = FactoryGirl.create(:artist, :name => "a")
          end

          should "find the artist" do
            assert_not_nil(@set.artist)
            assert_equal(@artist.id, @set.artist.id)
          end
        end
      end
    end
  end
end
