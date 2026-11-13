require "test_helper"

class ForumTopicTest < ActiveSupport::TestCase
  context "A forum topic" do
    setup do
      freeze_time
      @user = create(:user)
      @topic = create(:forum_topic, title: "xxx", creator: @user)
    end

    context "preloading the original post" do
      should "only load the first post of each topic" do
        topic2 = create(:forum_topic)
        op1 = create(:forum_post, topic: @topic)
        op2 = create(:forum_post, topic: topic2)
        create_list(:forum_post, 2, topic: @topic)
        create_list(:forum_post, 2, topic: topic2)

        loaded = 0
        callback = ->(*, payload) { loaded += payload[:record_count] if payload[:class_name] == "ForumPost" }
        topics = ActiveSupport::Notifications.subscribed(callback, "instantiation.active_record") do
          ForumTopic.where(id: [@topic.id, topic2.id]).order(:id).includes(:original_post).load
        end

        assert_equal([op1, op2], topics.map(&:original_post))
        assert_equal(2, loaded)
      end
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
          create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 1.day.ago)
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
          @topic = create(:forum_topic, creator: @user, title: "abc", original_post_attributes: { body: "abc", creator: @user })

          assert_equal(@user, @topic.creator)
          assert_equal(@user, @topic.updater)
          assert_equal(@user, @topic.original_post.creator)
          assert_equal(@user, @topic.original_post.updater)
        end
      end
    end

    should "be searchable by title" do
      assert_search_equals(@topic, title: "xxx")
      assert_search_equals([], title: "aaa")
    end

    should "be searchable by category id" do
      assert_search_equals(@topic, category_id: 0)
      assert_search_equals([], category_id: 1)
    end

    should "initialize its updater" do
      assert_equal(@user, @topic.updater)
    end

    context "with multiple posts" do
      should "delete all forum posts when the topic is deleted" do
        create_list(:forum_post, 5, topic: @topic)

        @topic.soft_delete!(updater: @user)

        assert_equal(true, @topic.forum_posts.all?(&:is_deleted?))
        assert_equal(true, @topic.forum_posts.all? { |post| post.updater == @user })
      end

      should "undelete all forum posts when the topic is undeleted" do
        create_list(:forum_post, 5, topic: @topic)

        @topic.soft_delete!(updater: @user)
        @topic.undelete!(updater: @user)

        assert_equal(true, @topic.forum_posts.none?(&:is_deleted?))
        assert_equal(true, @topic.forum_posts.all? { |post| post.updater == @user })
      end
    end

    context "during validation" do
      subject { build(:forum_topic) }

      should allow_value("General").for(:category)
      should allow_value("Tags").for(:category)
      should allow_value("Bugs & Features").for(:category)
      should allow_value("general").for(:category)
      should allow_value("tags").for(:category)
      should allow_value("bugs & features").for(:category)
      should allow_value(0).for(:category)
      should allow_value(1).for(:category)
      should allow_value(2).for(:category)

      should allow_value("None").for(:min_level)
      should allow_value("Member").for(:min_level)
      should allow_value("Gold").for(:min_level)
      should allow_value("Builder").for(:min_level)
      should allow_value("Moderator").for(:min_level)
      should allow_value("Admin").for(:min_level)

      should allow_value("none").for(:min_level)
      should allow_value("member").for(:min_level)
      should allow_value("gold").for(:min_level)
      should allow_value("builder").for(:min_level)
      should allow_value("moderator").for(:min_level)
      should allow_value("admin").for(:min_level)

      should allow_value(0).for(:min_level)
      should allow_value(20).for(:min_level)
      should allow_value(30).for(:min_level)

      should_not allow_value("unknown").for(:min_level)
      should_not allow_value(123_456_789).for(:min_level)

      should_not allow_value("unknown").for(:category)
      should_not allow_value(123_456_789).for(:category)

      should_not allow_value("").for(:title)
      should_not allow_value(" ").for(:title)
      should_not allow_value("\u200B").for(:title)
    end
  end
end
