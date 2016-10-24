require 'test_helper'

class ForumTopicsControllerTest < ActionController::TestCase
  context "The forum topics controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @other_user = FactoryGirl.create(:user)
      @mod = FactoryGirl.create(:moderator_user)
      @forum_topic = FactoryGirl.create(:forum_topic, :title => "my forum topic", :creator => @user, :original_post_attributes => {:body => "xxx"})
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "for a level restricted topic" do
      setup do
        @forum_topic.update_attribute(:min_level, 50)
      end

      should "not allow users to see the topic" do
        get :show, {:id => @forum_topic.id}  
        assert_redirected_to forum_topics_path
      end
    end

    context "show action" do
      should "render" do
        get :show, {:id => @forum_topic.id}
        assert_response :success
      end
    end

    context "index action" do
      should "list all forum topics" do
        get :index
        assert_response :success
      end

      context "with search conditions" do
        should "list all matching forum topics" do
          get :index, {:search => {:title_matches => "forum"}}
          assert_response :success
          assert_equal(1, assigns(:forum_topics).size)
        end

        should "list nothing for when the search matches nothing" do
          get :index, {:search => {:title_matches => "bababa"}}
          assert_response :success
          assert_equal(0, assigns(:forum_topics).size)
        end
      end
    end

    context "edit action" do
      should "render if the editor is the creator of the topic" do
        get :edit, {:id => @forum_topic.id}, {:user_id => @user.id}
        assert_response :success
      end

      should "render if the editor is a moderator" do
        get :edit, {:id => @forum_topic.id}, {:user_id => @mod.id}
        assert_response :success
      end

      should "fail if the editor is not the creator of the topic and is not a moderator" do
        get :edit, {:id => @forum_topic.id}, {:user_id => @other_user.id}
        assert_response(403)
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new forum topic and post" do
        assert_difference(["ForumPost.count", "ForumTopic.count"], 1) do
          post :create, {:forum_topic => {:title => "bababa", :original_post_attributes => {:body => "xaxaxa"}}}, {:user_id => @user.id}
        end

        forum_topic = ForumTopic.last
        assert_redirected_to(forum_topic_path(forum_topic))
      end
    end

    context "destroy action" do
      setup do
        @post = FactoryGirl.create(:forum_post, :topic_id => @forum_topic.id)
      end

      should "destroy the topic and any associated posts" do
        CurrentUser.user = @mod
        post :destroy, {:id => @forum_topic.id}, {:user_id => @mod.id}
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_equal(true, @forum_topic.is_deleted?)
      end
    end

    context "undelete action" do
      setup do
        @forum_topic.update_attribute(:is_deleted, true)
      end

      should "restore the topic" do
        CurrentUser.user = @mod
        post :undelete, {:id => @forum_topic.id}, {:user_id => @mod.id}
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert_equal(false, @forum_topic.is_deleted?)
      end
    end
  end
end
