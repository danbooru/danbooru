require "application_system_test_case"

class LoginChromeTest < ChromeSystemTestCase
  context "Login page:" do
    context "with a captcha" do
      setup do
        stub_captcha
        record_csp_violations
      end

      should "solve the Cloudflare Turnstile challenge and log in" do
        user = create(:user)
        visit login_path

        wait_for_captcha
        assert_no_csp_violations

        fill_in "Name", with: user.name
        fill_in "Password", with: user.password
        click_button "Login"

        assert_no_link "Login"
      end
    end
  end

  context "Logout page:" do
    should "log the user out" do
      fast_signin create(:user)
      visit logout_path

      assert_notice "You are now logged out"
      assert_link "Login"
    end
  end
end
