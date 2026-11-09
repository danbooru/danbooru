require "application_system_test_case"

class TOTPChromeTest < ChromeSystemTestCase
  context "The 2FA setup page" do
    should "show the secret code when clicking the 'Can't scan the code?' link" do
      user = create(:user)
      fast_signin user
      visit edit_user_totp_path(user)
      fill_in "Password", with: user.password
      click_button "Continue"

      assert_no_navigation { click_link "Can't scan the code?" }
      assert_text "If you can't scan the QR code"
    end
  end
end
