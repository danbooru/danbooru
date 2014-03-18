require 'test_helper'

class ForumTopicTest < ActiveSupport::TestCase
  context "A forum topic" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = FactoryGirl.create(:forum_topic, :title => "xxx")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#merge" do
      setup do
        @topic2 = FactoryGirl.create(:forum_topic, :title => "yyy")
        FactoryGirl.create(:forum_post, :topic_id => @topic.id, :body => "xxx")
        FactoryGirl.create(:forum_post, :topic_id => @topic2.id, :body => "xxx")
      end

      should "merge all the posts in one topic into the other" do
        @topic.merge(@topic2)
        assert_equal(2, @topic.posts.count)
      end
    end

    context "#read_by?" do
      context "for a topic that was never read by the user" do
        should "return false" do
          assert_equal(false, @topic.read_by?(@user, [[(@topic.id + 1).to_s, "1"]]))
        end
      end

      context "for a topic that was read by the user but has been updated since then" do
        should "return false" do
          assert_equal(false, @topic.read_by?(@user, [["#{@topic.id}", "#{1.day.ago.to_i}"]]))
        end
      end

      context "for a topic that was read by the user and has not been updated since" do
        should "return true" do
          assert_equal(true, @topic.read_by?(@user, [["#{@topic.id}", "#{1.day.from_now.to_i}"]]))
        end
      end
    end

    context "#mark_as_read" do
      should "include the topic id and updated_at timestamp" do
        plus_one = @topic.id + 1
        result = @topic.mark_as_read([["#{plus_one}", "2"]])
        assert_equal("#{plus_one} 2 #{@topic.id} #{@topic.updated_at.to_i}", result)
      end

      should "prune the string if it gets too long" do
        array = (1..1_000).to_a.map(&:to_s).in_groups_of(2)
        result = @topic.mark_as_read(array)
        assert_equal("502 503", result[0..6])
      end
    end

    context "constructed with nested attributes for its original post" do
      should "create a matching forum post" do
        assert_difference(["ForumTopic.count", "ForumPost.count"], 1) do
          @topic = FactoryGirl.create(:forum_topic, :title => "abc", :original_post_attributes => {:body => "abc"})
       end
      end
    end

    should "be searchable by title" do
      assert_equal(1, ForumTopic.title_matches("xxx").count)
      assert_equal(0, ForumTopic.title_matches("aaa").count)
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
        @second_user = FactoryGirl.create(:user)
        CurrentUser.user = @second_user
      end

      should "record its updater" do
        @topic.update_attributes(:title => "abc")
        assert_equal(@second_user.id, @topic.updater_id)
      end
    end

    context "with multiple posts that has been deleted" do
      setup do
        5.times do
          FactoryGirl.create(:forum_post, :topic_id => @topic.id)
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
