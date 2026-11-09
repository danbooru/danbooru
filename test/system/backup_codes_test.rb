require "application_system_test_case"

class BackupCodesChromeTest < ChromeSystemTestCase
  context "The backup codes page" do
    setup do
      @user = create(:user)
      stub_clipboard
      record_csp_violations
      fast_signin @user
      visit user_backup_codes_path(@user)
      fill_in "Password", with: @user.password
      click_button "Continue"
    end

    should "copy the backup codes" do
      click_button "Copy"

      assert_notice "Copied!"
      assert_clipboard all("#c-totp pre").map(&:text).join("\n")
      assert_no_csp_violations
    end

    should "print the backup codes" do
      click_button "Print"

      assert_selector "iframe[src='#{user_backup_codes_path(@user, format: :txt)}']", visible: false
      assert_no_csp_violations
    end
  end
end
