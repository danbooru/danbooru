require File.dirname(__FILE__) + '/../test_helper'

class ForumPostTest < ActiveSupport::TestCase
  context "A forum post" do
    should "update its parent when saved" do
      topic = Factory.create(:forum_topic)
      sleep 2
      post = Factory.create(:forum_post, :topic_id => topic.id)
      topic.reload
      assert(topic.updated_at > 1.second.ago)
    end
  end
end
