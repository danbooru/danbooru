require "application_system_test_case"

class IpAddressChromeTest < ChromeSystemTestCase
  context "IP address page:" do
    setup do
      IpLookup.any_instance.stubs(:response).returns({ location: { latitude: 35.68, longitude: 139.69 }}.with_indifferent_access)
      fast_signin(create(:mod_user))
      record_csp_violations
    end

    should "show the embedded Bing map without violating the Content-Security-Policy" do
      visit ip_address_path("1.2.3.4")

      within_frame(find("iframe[src^='https://www.bing.com/maps/embed']")) do
        assert_selector "#embedMap canvas.atlas-map-canvas"
      end

      assert_no_csp_violations
    end
  end
end
