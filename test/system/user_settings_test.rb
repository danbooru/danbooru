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

    should "enable and disable a beta feature in the Beta tab" do
      BetaFeature.stubs(:features).returns([BetaFeature.new(name: "test_feature", label: "Test feature", description: "A feature for testing.", released_to: "production")])
      visit edit_user_path(@user)

      find("a.beta-tab").click
      find("input[data-beta-feature='test_feature']").click
      visit edit_user_path(@user)
      assert_selector "body[data-beta-features='test_feature']"

      find("a.beta-tab").click
      find("input[data-beta-feature='test_feature']").click
      visit edit_user_path(@user)
      assert_selector "body[data-beta-features='']"
    end
  end
end
