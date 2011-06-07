require_relative '../../test_helper'

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
          id = ::Favorite.model_for(@user.id).where(:user_id => @user.id, :post_id => @post_3.id).first.id
          @set = PostSets::Base.new(:id => @user.id, :before_id => id)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Favorite)
        end

        context "a sequential paginator" do
          setup do
            @set.extend(PostSets::Sequential)
          end

          should "return the second most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set for after the second most recent post" do
        setup do
          id = ::Favorite.model_for(@user.id).where(:user_id => @user.id, :post_id => @post_2.id).first.id
          @set = PostSets::Base.new(:id => @user.id, :after_id => id)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Favorite)
        end

        context "a sequential paginator" do
          setup do
            @set.extend(PostSets::Sequential)
          end

          should "return the most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_3.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set for page 2" do
        setup do
          @set = PostSets::Base.new(:id => @user.id, :page => 2)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Favorite)
        end

        context "a numbered paginator" do
          setup do
            @set.extend(PostSets::Numbered)
          end

          should "return the second most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a favorite set with no page specified" do
        setup do
          @set = PostSets::Base.new(:id => @user.id)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Favorite)
        end

        context "a numbered paginator" do
          setup do
            @set.extend(PostSets::Numbered)
          end

          should "return the most recent element" do
            assert_equal(3, @set.count)
            assert_equal(1, @set.posts.size)
            assert_equal(@post_3.id, @set.posts.first.id)
          end
        end

        context "a sequential paginator" do
          setup do
            @set.extend(PostSets::Sequential)
          end
          
          should "return the most recent element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_3.id, @set.posts.first.id)
          end
        end
      end
    end
  end
end
