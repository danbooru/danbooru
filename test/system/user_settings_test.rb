require "application_system_test_case"

class UserSettingsChromeTest < ChromeSystemTestCase
  context "The settings page" do
    setup do
      @user = create(:user, theme: "light")
      fast_signin @user
      visit edit_user_path(@user)
    end

    should "set the current theme when the theme setting is changed" do
      find("label[for='user_theme_light']").click
      assert_selector "body[data-current-user-theme='light']"

      find("label[for='user_theme_dark']").click
      assert_selector "body[data-current-user-theme='dark']"

      find("label[for='user_theme_auto']").click
      assert_selector "body[data-current-user-theme='light']"
    end
  end
end
