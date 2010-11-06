require_relative '../test_helper'

class PostHistoryTest < ActiveSupport::TestCase
  context "A post" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
      PostHistory.stubs(:revision_time).returns("TIME")
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "create a revision after creation" do
      post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      assert_equal(1, post.revisions.size)
      assert_equal({"source"=>nil, "rating"=>"q", "tag_string"=>"aaa bbb ccc", "parent_id"=>nil, "user_id"=>@user.id, "ip_addr"=>"127.0.0.1", "updated_at"=>"TIME"}, post.revisions.last)
    end

    should "create additional revisions after updating" do
      post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      post.update_attributes(:tag_string => "bbb ccc ddd")
      post.reload
      assert_equal(2, post.revisions.size)
      assert_equal({"source"=>nil, "rating"=>"q", "tag_string"=>"bbb ccc ddd", "parent_id"=>nil, "user_id"=>@user.id, "ip_addr"=>"127.0.0.1", "updated_at"=>"TIME"}, post.revisions.last)
    end
    
    context "history" do
      setup do
        @post = Factory.create(:post, :tag_string => "aaa bbb ccc", :source => "xyz", :rating => "q")
        @post.update_attributes(:tag_string => "bbb ccc ddd", :source => "abc", :rating => "s")
        @post.update_attributes(:tag_string => "ccc ddd eee")
        @revisions = []
        @post.history.each_revision do |revision|
          @revisions << revision
        end
      end
      
      should "link revisions together" do
        assert_nil(@revisions[0].prev)
        assert_equal(@revisions[0], @revisions[1].prev)
        assert_equal(@revisions[1], @revisions[2].prev)
      end
      
      should "iterate over its revisions" do
        assert_equal(3, @revisions.size)
        assert_equal(%w(aaa bbb ccc), @revisions[0].tag_array)
        assert_equal(%w(bbb ccc ddd), @revisions[1].tag_array)
        assert_equal(%w(ccc ddd eee), @revisions[2].tag_array)
      end
      
      should "create a diff for each revision detailing what changed" do
        assert_equal({:add=>["aaa", "bbb", "ccc"], :del=>[], :rating=>"q", :source=>"xyz", :parent_id=>nil}, @revisions[0].diff)
        assert_equal({:del=>["aaa"], :add=>["ddd"], :rating=>"s", :source=>"abc"}, @revisions[1].diff)
        assert_equal({:del=>["bbb"], :add=>["eee"]}, @revisions[2].diff)
      end
    end
  end
end
