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

    context "that belongs to a topic with several pages of posts" do
      setup do
        Danbooru.config.stubs(:posts_per_page).returns(3)
        @posts = []
        9.times do
          @posts << FactoryGirl.create(:forum_post, :topic_id => @topic.id, :body => rand(100_000))
        end
        Timecop.travel(2.seconds.from_now) do
          @posts << FactoryGirl.create(:forum_post, :topic_id => @topic.id, :body => rand(100_000))
        end
      end

      should "know which page it's on" do
        assert_equal(2, @posts[3].forum_topic_page)
        assert_equal(2, @posts[4].forum_topic_page)
        assert_equal(2, @posts[5].forum_topic_page)
        assert_equal(3, @posts[6].forum_topic_page)
      end

      should "update the topic's updated_at when deleted" do
        @posts.last.destroy
        @topic.reload
        assert_equal(@posts[0].updated_at.to_s, @topic.updated_at.to_s)
      end
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
      Timecop.travel(1.second.from_now) do
        @original_topic_updated_at = @topic.updated_at
      end
      post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
      @topic.reload
      assert_not_equal(@original_topic_updated_at, @topic.updated_at)
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

    context "that is deleted" do
      setup do
        @post = FactoryGirl.create(:forum_post, :topic_id => @topic.id)
        @post.update_attribute(:is_deleted, true)
        @topic.reload
      end

      should "also delete the topic" do
        assert(@topic.is_deleted)
      end
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
