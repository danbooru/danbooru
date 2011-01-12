require_relative '../test_helper'

class ForumTopicTest < ActiveSupport::TestCase
  context "A forum topic" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = Factory.create(:forum_topic, :title => "xxx")
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "constructed with nested attributes for its original post" do
      should "create a matching forum post" do
        assert_difference(["ForumTopic.count", "ForumPost.count"], 1) do
          @topic = Factory.create(:forum_topic, :title => "abc", :original_post_attributes => {:body => "abc"})
       end 
      end
    end
    
    should "be searchable by title" do
      assert_equal(1, ForumTopic.title_matches("xxx").count)
      assert_equal(0, ForumTopic.title_matches("aaa").count)
    end
    
    should "initialize its creator" do
      assert_equal(@user.id, @topic.creator_id)
    end
    
    context "updated by a second user" do
      setup do
        @second_user = Factory.create(:user)
        CurrentUser.user = @second_user
      end
      
      should "record its updater" do
        @topic.update_attributes(:title => "abc")
        assert_equal(@second_user.id, @topic.updater_id)
      end
    end
  end
end
