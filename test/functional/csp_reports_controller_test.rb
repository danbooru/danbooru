require "test_helper"

class CSPReportsControllerTest < ActionDispatch::IntegrationTest
  context "The CSP reports controller" do
    context "create action" do
      should "log reports sent with report-uri" do
        report = { "csp-report": { "document-uri": "https://danbooru.donmai.us/posts", "violated-directive": "script-src-elem", "blocked-uri": "inline", "script-sample": "alert(1)\nalert(2)" }}

        post csp_reports_path, params: report.to_json, headers: { "Content-Type": "application/csp-report" }

        assert_response 204
      end

      should "log reports sent with report-to" do
        report = [{ type: "csp-violation", url: "https://danbooru.donmai.us/posts", body: { effectiveDirective: "img-src", blockedURL: "https://example.com/image.jpg" }}]

        post csp_reports_path, params: report.to_json, headers: { "Content-Type": "application/reports+json" }

        assert_response 204
      end

      should "reject invalid reports" do
        post csp_reports_path, params: "not json", headers: { "Content-Type": "application/csp-report" }

        assert_response 400
      end

      should "reject oversized reports" do
        report = { "csp-report": { "blocked-uri": "https://example.com/#{"a" * 20.kilobytes}" }}

        post csp_reports_path, params: report.to_json, headers: { "Content-Type": "application/csp-report" }

        assert_response 400
      end
    end
  end
end
