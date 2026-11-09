require "application_system_test_case"

class ReportsChromeTest < ChromeSystemTestCase
  context "The posts report" do
    should "draw a chart without violating the Content-Security-Policy" do
      create(:post)
      record_csp_violations
      visit report_path("posts", search: { mode: "chart", period: "day" })

      assert_selector ".line-chart canvas"
      assert_no_csp_violations
    end
  end
end
