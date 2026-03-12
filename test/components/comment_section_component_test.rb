require "test_helper"

class CommentSectionComponentTest < ViewComponent::TestCase
  def render_comment_section(post, current_user: User.anonymous, **options)
    as(current_user) do
      render_inline(CommentSectionComponent.new(post: post, current_user: current_user, **options))
    end
  end

  context "The CommentSectionComponent" do
    setup do
      as(create(:user)) do
        @post = create(:post)
        @comment = create_list(:comment, 7, post: @post)
      end
    end

    context "for a comment section with comments" do
      context "without a comment limit" do
        should "render" do
          render_comment_section(@post, current_user: User.anonymous)

          assert_css("div.comments-for-post")
          assert_css("article.comment", count: 7)
        end
      end

      context "for a logged-in user" do
        should "show the comment form link" do
          user = create(:user)

          render_comment_section(@post, current_user: user)

          assert_css("div.comments-for-post")
          assert_css("article.comment", count: 7)
          assert_css("a.expand-comment-response", text: "Leave a comment")
        end
      end

      context "with a comment limit" do
        context "higher than the actual number of comments" do
          should "render" do
            render_comment_section(@post, current_user: User.anonymous, limit: 8)

            assert_css("div.comments-for-post")
            assert_css("article.comment", count: 7)
          end
        end

        context "lower than the actual number of comments" do
          should "render" do
            render_comment_section(@post, current_user: User.anonymous, limit: 6)

            assert_css("div.comments-for-post")
            assert_css("article.comment", count: 6)
            assert_css("a.show-all-comments-link", text: "Show 1 more comment")
          end
        end
      end
    end

    context "for a comment section without comments" do
      should "render an empty message" do
        post = create(:post)

        render_comment_section(post, current_user: User.anonymous)

        assert_css("div.comments-for-post")
        assert_css("p", text: "There are no comments.")
        assert_no_css("article.comment")
      end
    end
  end
end
