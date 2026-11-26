require "application_system_test_case"

class BetaFeatureChromeTest < ChromeSystemTestCase
  context "BetaFeature.enabled" do
    should "return false on pages without the list of beta features" do
      # A null byte in a param raises an error before the current user is loaded, so the error page uses the blank
      # layout, which doesn't have `data-beta-features`. If the blank layout ever gets it, this test stops testing
      # anything, so the first assertion checks the attribute is really missing.
      visit posts_path(tags: "a\0b")

      assert_selector "body:not([data-beta-features])"
      assert_equal(false, page.evaluate_script("Danbooru.BetaFeature.enabled('test_feature')"))
    end
  end
end
