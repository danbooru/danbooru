require "application_system_test_case"

class SiteCredentialsChromeTest < ChromeSystemTestCase
  context "The new site credential page" do
    setup do
      @admin = create(:admin_user)
      fast_signin @admin
      visit new_site_credential_path
      fill_in "Password", with: @admin.password
      click_button "Continue"
    end

    should "show the fields for the selected site and require them before submitting" do
      assert_no_field "Phpsessid"

      select "Pixiv", from: "Site"
      assert_field "Phpsessid", visible: :visible

      assert_no_navigation { click_button "Create" }
      assert_selector "input[name='site_credential[credential][phpsessid]']:invalid", visible: :visible
      assert_equal(0, SiteCredential.count)

      fill_in "Phpsessid", with: "foo"
      click_button "Create"

      assert_current_path site_credentials_path
      assert_equal("Pixiv", SiteCredential.sole.site)
      assert_equal("foo", SiteCredential.sole.credential["phpsessid"])
    end
  end
end
