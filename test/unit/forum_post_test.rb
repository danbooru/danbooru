require 'test_helper'

class ForumPostTest < ActiveSupport::TestCase
  context "A forum post" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = FactoryGirl.create(:forum_topic)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "belonging to a locked topic" do
      setup do
        @post = FactoryGirl.create(:forum_post, :topic_id => @topic.id, :body => "zzz")
        @topic.update_attribute(:is_locked, true)
        @post.reload
      end
      
      should "not be updateable" do
        @post.update_attributes(:body => "xxx")
        @post.reload
        assert_equal("zzz", @post.body)
      end
      
      should "not be deletable" do
        @post.destroy
        assert_equal(1, ForumPost.count)
      end
    end
    
    should "update its parent when saved" do
      sleep 1
      original_topic_updated_at = @topic.updated_at
      post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
      @topic.reload
      assert_not_equal(original_topic_updated_at, @topic.updated_at)
    end
    
    should "be searchable by body content" do
      post = FactoryGirl.create(:forum_post, :topic_id => @topic.id, :body => "xxx")
      assert_equal(1, ForumPost.body_matches("xxx").count)
      assert_equal(0, ForumPost.body_matches("aaa").count)
    end
    
    should "initialize its creator" do
      post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
      assert_equal(@user.id, post.creator_id)
    end
    
    context "updated by a second user" do
      setup do
        @post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
        @second_user = FactoryGirl.create(:user)
        CurrentUser.user = @second_user
      end
      
      should "record its updater" do
        @post.update_attributes(:body => "abc")
        assert_equal(@second_user.id, @post.updater_id)
      end
    end
  end
end
