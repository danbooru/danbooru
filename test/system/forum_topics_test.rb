require "application_system_test_case"

module ForumTopicsTests
  extend ActiveSupport::Concern

  included do
    context "#{browser_name}:" do
      context "Forum topics:" do
        setup do
          @user = create(:user, created_at: 1.month.ago)
          @topic = create(:forum_topic, creator: @user, original_post: build(:forum_post, creator: @user, body: "the original post"))
          @forum_post = create(:forum_post, topic: @topic, creator: @user, body: "the original comment")
        end

        context "the post's Edit button" do
          setup do
            signin @user
            visit forum_topic_path(@topic)
          end

          should "reveal the post's edit form" do
            within "#forum_post_#{@forum_post.id}" do
              find(".popup-menu-button").click
              click_link "Edit"
            end

            assert_visible "#forum_post_#{@forum_post.id} .edit_forum_post"
            assert_equal @forum_post.body, find("#forum_post_#{@forum_post.id} .edit_forum_post textarea.dtext").value
          end
        end

        context "the post's dropdown menu" do
          setup do
            visit forum_topic_path(@topic)
          end

          should "copy the post's id when clicking Copy ID" do
            within "#forum_post_#{@forum_post.id}" do
              find(".popup-menu-button").click
              click_link "Copy ID"
            end

            assert_notice "Copied!"
            assert_clipboard "forum ##{@forum_post.id}"
          end

          should "copy the post's link when clicking Copy Link" do
            within "#forum_post_#{@forum_post.id}" do
              find(".popup-menu-button").click
              click_link "Copy Link"
            end

            assert_notice "Copied!"
            assert_clipboard(/#{Regexp.escape(forum_post_path(@forum_post))}\z/)
          end
        end

        context "clicking Reply on a post" do
          setup do
            signin @user
            visit forum_topic_path(@topic)
          end

          should "open the topic's reply form pre-filled with a quote of the post" do
            within "#forum_post_#{@forum_post.id}" do
              click_link "Reply"
            end

            editor_value = find("#topic-response textarea.dtext", visible: :visible).value
            assert_includes editor_value, "#{@user.name} said in forum ##{@forum_post.id}:"
            assert_includes editor_value, @forum_post.body
          end
        end

        context "the vote buttons on a bulk update request's post" do
          setup do
            @bur = create(:bulk_update_request, user: @user)

            signin @user
            visit forum_topic_path(@bur.forum_topic)
          end

          should "vote on the bur's post when clicked" do
            within "#forum-post-votes-for-#{@bur.forum_post.id}" do
              find("[title='Vote up']").click
            end

            assert_notice "Voted"
            assert_selector "#forum-post-votes-for-#{@bur.forum_post.id} .vote-score-up", text: @user.name
          end
        end

        context "the navbar's moderator controls" do
          setup do
            @moderator = create(:moderator_user, created_at: 1.month.ago)

            signin @moderator
            visit forum_topic_path(@topic)
          end

          should "ask for confirmation before locking the topic" do
            accept_confirm "Are you sure you want to lock this forum topic?" do
              find("#subnav-lock").click
            end

            assert_selector ".notice", text: "This topic has been locked."
          end

          should "ask for confirmation before stickying the topic" do
            accept_confirm "Are you sure you want to sticky this forum topic?" do
              find("#subnav-sticky").click
            end

            assert_selector "#subnav-unsticky"
          end

          should "ask for confirmation before deleting the topic" do
            accept_confirm "Are you sure you want to delete this forum topic?" do
              find("#subnav-delete").click
            end

            assert_selector "h1 .locked-topic", text: "(deleted)"
          end
        end

        context "deleting a forum post, as a moderator" do
          setup do
            @moderator = create(:moderator_user, created_at: 1.month.ago)

            signin @moderator
            visit forum_topic_path(@topic)
          end

          should "ask for confirmation before deleting the post" do
            within "#forum_post_#{@forum_post.id}" do
              find(".popup-menu-button").click
              accept_confirm "Are you sure you want to delete this forum post?" do
                click_link "Delete"
              end
            end

            assert_selector "#forum_post_#{@forum_post.id}[data-is-deleted='true']"
          end
        end
      end
    end
  end
end

class ForumTopicsChromeTest < ChromeSystemTestCase
  include ForumTopicsTests
end

class ForumTopicsFirefoxTest < FirefoxSystemTestCase
  include ForumTopicsTests
end

class ForumTopicsWebkitTest < WebkitSystemTestCase
  include ForumTopicsTests
end
