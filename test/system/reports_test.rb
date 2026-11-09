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

    should "set the start date to the first day when All Time is clicked" do
      create(:post, created_at: 3.years.ago)
      visit report_path("posts")

      assert_no_navigation { click_link "All Time" }
      assert_equal(3.years.ago.to_date.iso8601, find_field("search_from").value)
    end
  end
end
