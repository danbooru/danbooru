require "application_system_test_case"

class DmailsChromeTest < ChromeSystemTestCase
  context "Dmails:" do
    should "copy the share link to the clipboard when clicking Share" do
      user = create(:user)
      dmail = create(:dmail, owner: user, to: user)
      stub_clipboard
      fast_signin user
      visit dmail_path(dmail)

      assert_no_navigation { click_link "Share" }

      assert_notice "Share link copied to clipboard"
      assert_clipboard(/#{Regexp.escape(dmail_path(dmail, key: dmail.key))}\z/)
    end
  end
end
