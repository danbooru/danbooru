require "application_system_test_case"

class PasswordResetChromeTest < ChromeSystemTestCase
  context "Password reset page:" do
    context "with a captcha" do
      setup do
        stub_captcha
        record_csp_violations
      end

      should "solve the Cloudflare Turnstile challenge and request a password reset" do
        user = create(:user)
        visit password_reset_path

        wait_for_captcha
        assert_no_csp_violations

        fill_in "Name or Email", with: user.name
        click_button "Reset password"

        assert_notice(/Check your email/)
      end
    end
  end
end
