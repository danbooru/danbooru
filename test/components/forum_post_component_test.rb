require "test_helper"

class ForumPostComponentTest < ViewComponent::TestCase
  def render_forum_post(forum_post, current_user: User.anonymous, **options)
    as(current_user) do
      render_inline(ForumPostComponent.new(forum_post: forum_post, current_user: current_user, **options))
    end
  end

  context "The ForumPostComponent" do
    setup do
      @forum_post = as(create(:user)) { create(:forum_post) }
    end

    context "for a regular forum post" do
      should "render for Anonymous" do
        render_forum_post(@forum_post, current_user: User.anonymous)

        assert_css("article#forum_post_#{@forum_post.id}")
      end

      should "render for a Member" do
        render_forum_post(@forum_post, current_user: create(:user))

        assert_css("article#forum_post_#{@forum_post.id}")
      end
    end

    context "for a forum post with moderation reports" do
      should "show the report notice to moderators" do
        create(:moderation_report, model: @forum_post)
        render_forum_post(@forum_post, current_user: create(:moderator_user))

        assert_css(".moderation-report-notice")
      end

      should "not show the report notice to regular users" do
        render_forum_post(@forum_post, current_user: create(:user))

        assert_no_css(".moderation-report-notice")
      end
    end
  end
end
