require 'test_helper'

class FavoriteTest < ActiveSupport::TestCase
  def setup
    super
    @user = FactoryBot.create(:user)
    CurrentUser.user = @user
    CurrentUser.ip_addr = "127.0.0.1"
    @fav_group = FactoryBot.create(:favorite_group, creator: @user, name: "blah")
  end

  def teardown
    super
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "searching by post id" do
    context "when the id is the only one" do
      setup do
        @fav_group.post_ids = "1"
        @fav_group.save
      end

      should "return the fav group" do
        assert_equal(@fav_group.id, FavoriteGroup.for_post(1).first.try(:id))
      end
    end

    context "when the id is in the beginning" do
      setup do
        @fav_group.post_ids = "1 2"
        @fav_group.save
      end

      should "return the fav group" do
        assert_equal(@fav_group.id, FavoriteGroup.for_post(1).first.try(:id))
      end      
    end

    context "when the id is in the middle" do
      setup do
        @fav_group.post_ids = "3 1 2"
        @fav_group.save
      end

      should "return the fav group" do
        assert_equal(@fav_group.id, FavoriteGroup.for_post(1).first.try(:id))
      end
    end

    context "when the id is in the end" do
      setup do
        @fav_group.post_ids = "2 1"
        @fav_group.save
      end

      should "return the fav group" do
        assert_equal(@fav_group.id, FavoriteGroup.for_post(1).first.try(:id))
      end  
    end
  end

  context "expunging a post" do
    setup do
      @post = FactoryBot.create(:post)
      @fav_group.add!(@post)
    end

    should "remove it from all favorite groups" do
      assert_equal("#{@post.id}", @fav_group.post_ids)
      @post.expunge!
      @fav_group.reload
      assert_equal("", @fav_group.post_ids)
    end
  end
end
