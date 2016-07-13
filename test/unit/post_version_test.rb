require 'test_helper'

class PostVersionTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      Timecop.travel(1.month.ago) do
        @user = FactoryGirl.create(:user)
      end
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "that has multiple versions: " do
      setup do
        @post = FactoryGirl.create(:post, :tag_string => "1")
        @post.stubs(:merge_version?).returns(false)
        @post.stubs(:tag_string_changed?).returns(true)
        @post.update_attributes(:tag_string => "1 2")
        @post.update_attributes(:tag_string => "2 3")
      end

      context "a version record" do
        setup do
          @version = PostVersion.last
        end

        should "know its previous version" do
          assert_not_nil(@version.previous)
          assert_equal("1 2", @version.previous.tags)
        end

        should "know the seuqence of all versions for the post" do
          assert_equal(2, @version.sequence_for_post.size)
          assert_equal(%w(3), @version.sequence_for_post[0][:added_tags])
          assert_equal(%w(2), @version.sequence_for_post[1][:added_tags])
        end
      end
    end

    context "that has been created" do
      setup do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "e", :parent => @parent, :source => "xyz")
      end

      should "also create a version" do
        assert_equal(1, @post.versions.size)
        @version = @post.versions.last
        assert_equal("aaa bbb ccc", @version.tags)
        assert_equal(@post.rating, @version.rating)
        assert_equal(@post.parent_id, @version.parent_id)
        assert_equal(@post.source, @version.source)
      end
    end

    context "that should be merged" do
      setup do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
      end

      should "delete the previous version" do
        assert_equal(1, @post.versions.count)
        @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "")
        @post.reload
        assert_equal(1, @post.versions.count)
      end
    end

    context "that has been updated" do
      setup do
        @parent = FactoryGirl.create(:post)
        @post = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
        @post.stubs(:merge_version?).returns(false)
        @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "")
      end

      should "also create a version" do
        assert_equal(2, @post.versions.size)
        @version = @post.versions.last
        assert_equal("bbb ccc xxx", @version.tags)
        assert_equal("q", @version.rating)
        assert_equal("", @version.source)
        assert_nil(@version.parent_id)
      end
    end
  end
end
