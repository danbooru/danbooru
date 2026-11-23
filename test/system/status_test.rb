require "application_system_test_case"

class StatusChromeTest < ChromeSystemTestCase
  context "The status page" do
    should "show the browser's metadata" do
      # Process.ppid is 0 when the tests are started with `docker exec`, so /proc/<ppid> doesn't exist.
      ServerStatus.any_instance.stubs(:instance_uptime).returns("1 day")
      visit status_path
      find("summary", text: "Mozilla").click

      assert_selector "th", text: "browser.userAgent"
      assert_selector "td", text: "Mozilla"
    end
  end
end
