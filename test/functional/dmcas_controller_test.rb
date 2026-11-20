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
      Danbooru.config.stubs(:dmca_email).returns("dmca@danbooru.example.com")
    end

    should "create a pending DMCA request and email it to the DMCA address and the submitter in the background" do
      post dmca_path, params: { dmca: @valid_dmca }

      assert_response :success
      dmca_request = DmcaRequest.last
      assert_equal("pending", dmca_request.status)
      assert_equal(@valid_dmca, dmca_request.attributes.symbolize_keys.slice(*@valid_dmca.keys))

      assert_emails 0
      perform_enqueued_jobs
      assert_equal([["dmca@danbooru.example.com"], ["test@gmail.com"]].sort, ActionMailer::Base.deliveries.map(&:to).sort)
    end

    should "not send an email to fake addresses" do
      post dmca_path, params: { dmca: { **@valid_dmca, email: "fake@example.com" }}

      assert_response :success
      assert_equal("fake@example.com", DmcaRequest.last.email)

      perform_enqueued_jobs
      assert_equal([["dmca@danbooru.example.com"]], ActionMailer::Base.deliveries.map(&:to))
    end

    should "return 400 for a missing complaint" do
      post dmca_path

      assert_response 400
      assert_equal(0, DmcaRequest.count)
      assert_enqueued_emails 0
    end

    should "not allow setting the status" do
      post dmca_path, params: { dmca: { **@valid_dmca, status: "handled" }}

      assert_response 403
      assert_equal(0, DmcaRequest.count)
      assert_enqueued_emails 0
    end

    should "show the errors and keep the submitted values when the request is invalid" do
      post dmca_path, params: { dmca: { **@valid_dmca, email: "not an email" }, perjury_agree: "on" }

      assert_response 422
      assert_equal(0, DmcaRequest.count)
      assert_enqueued_emails 0

      assert_select "#notice", text: /Email is invalid/
      assert_select "input[name='dmca[name]'][value='John Doe']"
      assert_select "input[name='dmca[email]'][value='not an email']"
      assert_select "textarea[name='dmca[address]']", text: "123 Fake Street"
      assert_select "textarea[name='dmca[infringing_urls]']", text: /2\.html/
      assert_select "textarea[name='dmca[proof]']", text: "source: me"
      assert_select "input[name='perjury_agree'][checked]"
      assert_select "input[name='good_faith_agree'][checked]", count: 0
    end
  end
end
