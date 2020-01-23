require 'test_helper'

class ForumTopicTest < ActiveSupport::TestCase
  context "A forum topic" do
    setup do
      travel_to Time.now
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = create(:forum_topic, title: "xxx", creator: @user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#mark_as_read!" do
      context "without a previous visit" do
        should "create a new visit" do
          @topic.mark_as_read!(@user)
          @user.reload
          assert_equal(@topic.updated_at.to_i, @user.last_forum_read_at.to_i)
        end
      end

      context "with a previous visit" do
        setup do
          FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 1.day.ago)
        end

        should "update the visit" do
          @topic.mark_as_read!(@user)
          @user.reload
          assert_equal(@topic.updated_at.to_i, @user.last_forum_read_at.to_i)
        end
      end
    end

    context "constructed with nested attributes for its original post" do
      should "create a matching forum post" do
        assert_difference(["ForumTopic.count", "ForumPost.count"], 1) do
          @topic = create(:forum_topic, title: "abc", original_post_attributes: { body: "abc", creator: @user })
        end
      end
    end

    should "be searchable by title" do
      assert_equal(1, ForumTopic.search(title: "xxx").count)
      assert_equal(0, ForumTopic.search(title: "aaa").count)
    end

    should "be searchable by category id" do
      assert_equal(1, ForumTopic.search(:category_id => 0).count)
      assert_equal(0, ForumTopic.search(:category_id => 1).count)
    end

    should "initialize its creator" do
      assert_equal(@user.id, @topic.creator_id)
    end

    context "updated by a second user" do
      setup do
        @second_user = FactoryBot.create(:user)
        CurrentUser.user = @second_user
      end

      should "record its updater" do
        @topic.update(title: "abc")
        assert_equal(@second_user.id, @topic.updater_id)
      end
    end

    context "with multiple posts that has been deleted" do
      setup do
        5.times do
          FactoryBot.create(:forum_post, :topic_id => @topic.id)
        end
      end

      should "delete any associated posts" do
        assert_difference("ForumPost.count", -5) do
          @topic.destroy
        end
      end
    end
  end
end
