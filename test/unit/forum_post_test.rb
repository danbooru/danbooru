require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase
  context "A forum post" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = Factory.create(:forum_topic)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "update its parent when saved" do
      sleep 1
      original_topic_updated_at = @topic.updated_at
      post = Factory.create(:forum_post, :topic_id => @topic.id)
      @topic.reload
      assert_not_equal(original_topic_updated_at, @topic.updated_at)
    end
    
    should "be searchable by body content" do
      post = Factory.create(:forum_post, :topic_id => @topic.id, :body => "xxx")
      assert_equal(1, ForumPost.body_matches("xxx").count)
      assert_equal(0, ForumPost.body_matches("aaa").count)
    end
    
    should "initialize its creator" do
      post = Factory.create(:forum_post, :topic_id => @topic.id)
      assert_equal(@user.id, post.creator_id)
    end
    
    context "updated by a second user" do
      setup do
        @post = Factory.create(:forum_post, :topic_id => @topic.id)
        @second_user = Factory.create(:user)
        CurrentUser.user = @second_user
      end
      
      should "record its updater" do
        @post.update_attributes(:body => "abc")
        assert_equal(@second_user.id, @post.updater_id)
      end
    end
  end
end
