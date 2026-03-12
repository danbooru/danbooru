require "test_helper"

class UserProfileComponentTest < ViewComponent::TestCase
  def render_user(user, viewer: user)
    as(viewer) { render_inline(UserProfileComponent.new(user: user, current_user: viewer)) }
  end

  context "The UserProfileComponent" do
    setup do
      @user = create(:user, :with_email)
      @post = create(:post, uploader: @user, created_at: 10.days.ago)
      @points_to_max = UploadLimit.level_to_points(UploadLimit.points_to_level(UploadLimit::MAXIMUM_POINTS))
    end

    should "render" do
      render_user(@user)
      assert_text(@user.pretty_name)
    end

    should "show maximum slots reached" do
      @user.update!(upload_points: @points_to_max)
      render_user(@user)
      assert_selector("abbr[title='Maximum amount of upload slots reached.']", text: "40")
    end

    should "show points to next level" do
      @user.update!(upload_points: @points_to_max - 1)
      render_user(@user)
      assert_selector("abbr[title*='1 approved post needed for next level']", text: "39")
    end

    should "show personal information when a user views their own profile" do
      render_user(@user, viewer: @user)

      assert_css("th", text: "Votes")
      assert_css("th", text: "API Key")
      assert_css(".user-email-address")
      assert_no_css("th", text: "Last Seen")
      assert_no_css("th", text: "Last IP")
    end

    should "not show personal information when a user views someone else's profile" do
      render_user(@user, viewer: create(:user))

      assert_no_css("th", text: "Votes")
      assert_no_css("th", text: "API Key")
      assert_no_css(".user-email-address")
      assert_no_css("th", text: "Last Seen")
      assert_no_css("th", text: "Last IP")
    end

    should "show everything when an admin views a user's profile" do
      admin = create(:admin_user)
      create(:favorite, user: @user, post: create(:post))
      create(:saved_search, user: @user, labels: ["alpha"], query: ["blue_hair"])
      create(:post, approver: @user)
      create(:post_flag, creator: @user, post: create(:post), reason: "bad")
      create(:moderation_report, creator: @user, model: create(:comment), reason: "submitted")
      create(:moderation_report, creator: create(:user), model: create(:comment, creator: @user), reason: "received")
      create(:user_name_change_request, user: @user, original_name: "old_name", desired_name: "new_name")

      render_user(@user, viewer: admin)

      assert_css("th", text: "Votes")
      assert_no_css("th", text: "API Key")
      assert_css(".user-email-address")
      assert_css("th", text: "Last Seen")
      assert_css("th", text: "Last IP")
      assert_css(".user-uploads .recent-posts-header", text: "Posts")
      assert_css(".user-favorites .recent-posts-header", text: "Favorites")
      assert_no_css("th", text: "Saved Searches")
      assert_css("th", text: "Approvals")
      assert_css("th", text: "Flags")
      assert_css("th", text: "Mod Reports")
      assert_css("th", text: "Previous Names")
      assert_text("old_name")
    end
  end
end
