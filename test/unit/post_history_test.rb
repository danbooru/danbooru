require_relative '../test_helper'

class PostHistoryTest < ActiveSupport::TestCase
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

    should "create a revision after creation" do
      PostHistory.stubs(:revision_time).returns("TIME")
      post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      assert_equal(1, post.revisions.size)
      assert_equal({"source"=>nil, "rating"=>"q", "tag_string"=>"aaa bbb ccc", "parent_id"=>nil, "user_id"=>1, "ip_addr"=>"127.0.0.1", "updated_at"=>"TIME"}, post.revisions.last)
    end

    should "create additional revisions after updating" do
      PostHistory.stubs(:revision_time).returns("TIME")
      post = Factory.create(:post, :tag_string => "aaa bbb ccc")
      post.update_attributes(:tag_string => "bbb ccc ddd")
      post.reload
      assert_equal(2, post.revisions.size)
      assert_equal({"source"=>nil, "rating"=>"q", "tag_string"=>"bbb ccc ddd", "parent_id"=>nil, "user_id"=>3, "ip_addr"=>"127.0.0.1", "updated_at"=>"TIME"}, post.revisions.last)
    end
  end
end
