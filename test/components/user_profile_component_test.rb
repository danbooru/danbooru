require "test_helper"

class UserProfileComponentTest < ViewComponent::TestCase
  def render_user(user)
    as(@user) { render_inline(UserProfileComponent.new(user: user, current_user: user)) }
  end

  context "The UserUploadComponent" do
    setup do
      @user = create(:user)
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
  end
end
