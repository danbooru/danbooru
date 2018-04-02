require 'test_helper'

class ForumTopicTest < ActiveSupport::TestCase
  context "A forum topic" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @topic = FactoryBot.create(:forum_topic, :title => "xxx")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#read_by?" do
      context "with a populated @user.last_forum_read_at" do
        setup do
          @user.update_attribute(:last_forum_read_at, Time.now)
        end

        context "and no visits for a topic" do
          setup do
            @topic.update_column(:updated_at, 1.day.from_now)
          end

          should "return false" do
            assert_equal(false, @topic.read_by?(@user))
          end
        end

        context "and a visit for a topic" do
          setup do
            @topic.update_column(:updated_at, 1.day.from_now)
          end

          context "that predates the topic" do
            setup do
              FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 16.hours.from_now)
            end

            should "return false" do
              assert_equal(false, @topic.read_by?(@user))
            end
          end

          context "that postdates the topic" do
            setup do
              FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 2.days.from_now)
            end            

            should "return true" do
              assert_equal(true, @topic.read_by?(@user))
            end
          end
        end
      end

      context "with a blank @user.last_forum_read_at" do
        context "and no visits" do
          should "return false" do
            assert_equal(false, @topic.read_by?(@user))
          end
        end

        context "and a visit" do
          context "that predates the topic" do
            setup do
              FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 1.day.ago)
            end

            should "return false" do
              assert_equal(false, @topic.read_by?(@user))
            end
          end

          context "that postdates the topic" do
            setup do
              FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 1.days.from_now)
            end

            should "return true" do
              assert_equal(true, @topic.read_by?(@user))
            end
          end
        end
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
          FactoryBot.create(:forum_topic_visit, user: @user, forum_topic: @topic, last_read_at: 1.day.ago)
        end

        should "update the visit" do
          @topic.mark_as_read!(@user)
          @user.reload
          assert_equal(@topic.updated_at.to_i, @user.last_forum_read_at.to_i)
        end
      end
    end

    context "#merge" do
      setup do
        @topic2 = FactoryBot.create(:forum_topic, :title => "yyy")
        FactoryBot.create(:forum_post, :topic_id => @topic.id, :body => "xxx")
        FactoryBot.create(:forum_post, :topic_id => @topic2.id, :body => "xxx")
      end

      should "merge all the posts in one topic into the other" do
        @topic.merge(@topic2)
        assert_equal(2, @topic2.posts.count)
      end
    end

    context "constructed with nested attributes for its original post" do
      should "create a matching forum post" do
        assert_difference(["ForumTopic.count", "ForumPost.count"], 1) do
          @topic = FactoryBot.create(:forum_topic, :title => "abc", :original_post_attributes => {:body => "abc"})
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
        @second_user = FactoryBot.create(:user)
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
