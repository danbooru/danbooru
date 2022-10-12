require "test_helper"

class DmcasControllerTest < ActionDispatch::IntegrationTest
  context "show action" do
    should "work for anonymous users" do
      get dmca_path
      assert_response :success
    end
  end

  context "create action" do
    should "work" do
      dmca = {
        name: "John Doe",
        email: "test@example.com",
        address: "123 Fake Street",
        infringing_urls: "https://example.com/1.html\nhttps://example.com/2.html",
        original_urls: "https://google.com/1.html\nhttps://google.com/2.html",
        proof: "source: me",
        signature: "John Doe",
      }

      create(:owner_user)
      post dmca_path, params: { dmca: dmca }

      assert_response :success
      assert_emails 2
      assert_equal("DMCA Complaint from John Doe", Dmail.last.title)
      assert_match(/test@example.com/, Dmail.last.body)
      assert_match(%r{https://example\.com/1\.html}, Dmail.last.body)
    end
  end
end
