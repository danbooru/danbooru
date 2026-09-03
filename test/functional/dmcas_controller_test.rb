require "test_helper"

class DmcasControllerTest < ActionDispatch::IntegrationTest
  context "show action" do
    should "work for anonymous users" do
      get dmca_path
      assert_response :success
    end
  end

  context "create action" do
    setup do
      @valid_dmca = {
        name: "John Doe",
        email: "test@gmail.com",
        address: "123 Fake Street",
        infringing_urls: "https://example.com/1.html\nhttps://example.com/2.html",
        original_urls: "https://google.com/1.html\nhttps://google.com/2.html",
        proof: "source: me",
        signature: "John Doe",
      }

      @owner = create(:owner_user)
    end

    should "work" do
      post dmca_path, params: { dmca: @valid_dmca }

      assert_response :success
      assert_emails 2
      assert_equal("DMCA Complaint from John Doe", Dmail.last.title)
      assert_match(/test@gmail.com/, Dmail.last.body)
      assert_match(%r{https://example\.com/1\.html}, Dmail.last.body)
    end

    should "not send an email to fake addresses" do
      dmca = {
        name: "John Doe",
        email: "fake@example.com",
        address: "123 Fake Street",
        infringing_urls: "https://example.com/1.html\nhttps://example.com/2.html",
        original_urls: "https://google.com/1.html\nhttps://google.com/2.html",
        proof: "source: me",
        signature: "John Doe",
      }

      post dmca_path, params: { dmca: dmca }

      assert_response :success
      assert_emails 1
      assert_equal("DMCA Complaint from John Doe", Dmail.last.title)
      assert_match(/fake@example.com/, Dmail.last.body)
      assert_match(%r{https://example\.com/1\.html}, Dmail.last.body)
    end

    should "send the notification to the same owner every time when there are multiple owners" do
      create(:owner_user)

      10.times { post dmca_path, params: { dmca: @valid_dmca } }

      assert_equal([@owner.id] * 5, Dmail.last(5).map(&:owner_id))
    end
  end
end
