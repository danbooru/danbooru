require "application_system_test_case"

class SignupChromeTest < ChromeSystemTestCase
  context "Signup page:" do
    context "with a captcha" do
      setup do
        stub_captcha
        record_csp_violations
      end

      should "solve the Cloudflare Turnstile challenge and sign up" do
        visit new_user_path

        wait_for_captcha
        assert_no_csp_violations

        fill_in "Username", with: "new_user"
        fill_in "Password", with: "password"
        fill_in "Confirm password", with: "password"
        click_button "Sign up"

        assert_no_link "Login"
        assert_equal(true, User.exists?(name: "new_user"))
      end
    end
  end
end
