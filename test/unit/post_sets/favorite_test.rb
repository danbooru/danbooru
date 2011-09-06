require File.expand_path('../../../test_helper',  __FILE__)

module PostSets
  class FavoriteTest < ActiveSupport::TestCase
    context "In all cases" do
      setup do
        @user = Factory.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        MEMCACHE.flush_all

        @post_1 = Factory.create(:post)
        @post_2 = Factory.create(:post)
        @post_3 = Factory.create(:post)
        @post_2.add_favorite!(@user)
        @post_1.add_favorite!(@user)
        @post_3.add_favorite!(@user)
      end
      
      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end
      
      context "a favorite set for before the most recent post" do
        setup do
          id = ::Favorite.where(:user_id => @user.id, :post_id => @post_3.id).first.id
          ::Favorite.stubs(:records_per_page).returns(1)
          @set = PostSets::Favorite.new(@user.id, "b#{id}")
        end

        context "a sequential paginator" do
          should "return the second most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set for after the second most recent post" do
        setup do
          id = ::Favorite.where(:user_id => @user.id, :post_id => @post_2.id).first.id
          ::Favorite.stubs(:records_per_page).returns(1)
          @set = PostSets::Favorite.new(@user.id, "a#{id}")
        end

        context "a sequential paginator" do
          should "return the most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set for page 2" do
        setup do
          ::Favorite.stubs(:records_per_page).returns(1)
          @set = PostSets::Favorite.new(@user.id, 2)
        end

        context "a numbered paginator" do
          should "return the second most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set with no page specified" do
        setup do
          ::Favorite.stubs(:records_per_page).returns(1)
          @set = PostSets::Favorite.new(@user.id)
        end

        should "return the most recent element" do
          assert_equal(1, @set.posts.size)
          assert_equal(@post_3.id, @set.posts.first.id)
        end
      end
    end
  end
end
