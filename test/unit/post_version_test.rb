require 'test_helper'

class PostVersionTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "that has been created" do
      setup do
        @parent = Factory.create(:post)
        @post = Factory.create(:post, :tag_string => "aaa bbb ccc", :rating => "e", :parent => @parent, :source => "xyz")
      end
      
      should "also create a version" do
        assert_equal(1, @post.versions.size)
        @version = @post.versions.last
        assert_equal("aaa bbb ccc", @version.add_tags)
        assert_equal("", @version.del_tags)
        assert_equal(@post.rating, @version.rating)
        assert_equal(@post.parent_id, @version.parent_id)
        assert_equal(@post.source, @version.source)
      end
    end
    
    context "that has been updated" do
      setup do
        @parent = Factory.create(:post)
        @post = Factory.create(:post, :tag_string => "aaa bbb ccc", :rating => "q", :source => "xyz")
        @post.update_attributes(:tag_string => "bbb ccc xxx", :source => "")
      end
      
      should "also create a version" do
        assert_equal(2, @post.versions.size)
        @version = @post.versions.last
        assert_equal("xxx", @version.add_tags)
        assert_equal("aaa", @version.del_tags)
        assert_nil(@version.rating)
        assert_equal("", @version.source)
        assert_nil(@version.parent_id)
      end
    end
  end
end
