require "application_system_test_case"

class CommentsChromeTest < ChromeSystemTestCase
  context "Comments:" do
    setup do
      @user = create(:user, created_at: 1.month.ago)
      @post = create(:post)
    end

    context "a comment below the score threshold" do
      setup do
        @comment = as(@user) { create(:comment, post: @post, score: -10) }
        visit post_path(@post)
      end

      should "be hidden, and become visible when clicked" do
        assert_hidden "#comment_#{@comment.id} .body"

        find("#comment_#{@comment.id} .unhide-comment-link").click

        assert_visible "#comment_#{@comment.id} .body", text: @comment.body
      end
    end

    context "the comment's dropdown menu" do
      setup do
        stub_clipboard

        @comment = as(@user) { create(:comment, post: @post) }
        visit post_path(@post)
      end

      should "copy the comment's id when clicking Copy ID" do
        within "#comment_#{@comment.id}" do
          find(".popup-menu-button").click
          click_link "Copy ID"
        end

        assert_notice "Copied!"

        assert_clipboard "comment ##{@comment.id}"
      end

      should "copy the comment's link when clicking Copy Link" do
        within "#comment_#{@comment.id}" do
          find(".popup-menu-button").click
          click_link "Copy Link"
        end

        assert_notice "Copied!"
        assert_clipboard(/#{Regexp.escape(comment_path(@comment))}\z/)
      end
    end

    context "the comment's dropdown menu, as a moderator" do
      setup do
        @moderator = create(:moderator_user, created_at: 1.month.ago)
        @comment = as(@moderator) { create(:comment, post: @post) }

        fast_signin @moderator
        visit post_path(@post)
      end

      should "ask for confirmation before deleting the comment" do
        within "#comment_#{@comment.id}" do
          find(".popup-menu-button").click
          click_and_accept_confirm(find_link("Delete"), "Are you sure you want to delete this comment?")
        end

        assert_selector "#comment_#{@comment.id}[data-is-deleted='true']"
      end

      should "ask for confirmation before stickying the comment" do
        within "#comment_#{@comment.id}" do
          find(".popup-menu-button").click
          click_and_accept_confirm(find_link("Sticky"), "Are you sure you want to sticky this comment?")
        end

        assert_selector "#comment_#{@comment.id}[data-is-sticky='true']"
      end
    end

    context "clicking Reply on a comment" do
      setup do
        @comment = as(@user) { create(:comment, creator: @user, post: @post, body: "the original comment") }

        fast_signin @user
        visit post_path(@post)
      end

      should "open the comment form pre-filled with a quote of the comment" do
        within "#comment_#{@comment.id}" do
          click_link "Reply"
        end

        editor_value = find(".new-comment textarea.dtext", visible: :visible).value
        assert_includes editor_value, "#{@user.name} said in comment ##{@comment.id}:"
        assert_includes editor_value, @comment.body
      end
    end

    context "clicking a quoted comment" do
      setup do
        @quoted_comment = as(@user) { create(:comment, post: @post, body: "the original comment") }
        @reply_comment = as(@user) { create(:comment, post: @post, body: @quoted_comment.quoted_response) }

        visit post_path(@post)
      end

      should "select the quoted comment without reloading the page" do
        within "#comment_#{@reply_comment.id}" do
          find(".dtext-comment-id-link").click
        end

        assert_equal "comment_#{@quoted_comment.id}", page.evaluate_script("document.querySelector(':target')?.id")
        assert page.current_url.end_with?("#comment_#{@quoted_comment.id}")
      end
    end
  end
end
