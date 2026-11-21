require "test_helper"

class DmcaRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The DMCA requests controller" do
    setup do
      @superadmin = create(:superadmin_user)
      @admin = create(:admin_user)
      @dmca_request = create(:dmca_request, infringing_urls: "https://example.com/1.html\njavascript:alert(1)")
    end

    context "index action" do
      should "render for the superadmin" do
        get_auth dmca_requests_path, @superadmin, reauthenticate: true

        assert_response :success
        assert_select "tr#dmca-request-#{@dmca_request.id}"
      end

      should "support searching by status" do
        handled = create(:dmca_request, status: :handled, updater: @superadmin)
        get_auth dmca_requests_path(search: { status: "handled" }), @superadmin, reauthenticate: true

        assert_response :success
        assert_select "tr#dmca-request-#{handled.id}"
        assert_select "tr#dmca-request-#{@dmca_request.id}", count: 0
      end

      should "support searching by exact name and email" do
        other = create(:dmca_request, name: "Jane Doe", email: "other@gmail.com")

        get_auth dmca_requests_path(search: { name: "Jane Doe" }), @superadmin, reauthenticate: true
        assert_response :success
        assert_select "tr#dmca-request-#{other.id}"
        assert_select "tr#dmca-request-#{@dmca_request.id}", count: 0

        get_auth dmca_requests_path(search: { email: "other@gmail.com" }), @superadmin, reauthenticate: true
        assert_response :success
        assert_select "tr#dmca-request-#{other.id}"
        assert_select "tr#dmca-request-#{@dmca_request.id}", count: 0
      end

      should "render requests with purged personal info" do
        @dmca_request.update!(status: :handled, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day, updater: @superadmin)
        DmcaRequest.prune!
        get_auth dmca_requests_path, @superadmin, reauthenticate: true

        assert_response :success
        assert_select "tr#dmca-request-#{@dmca_request.id}"
      end

      should "render the json for the superadmin" do
        get_auth dmca_requests_path(format: :json), @superadmin, reauthenticate: true

        assert_response :success
        assert_equal([@dmca_request.id], response.parsed_body.pluck("id"))
      end

      should "require the superadmin to reauthenticate" do
        get_auth dmca_requests_path, @superadmin
        assert_redirected_to confirm_password_session_path(url: dmca_requests_path)
      end

      should "not work with an API key" do
        api_key = create(:api_key, user: @superadmin)
        get dmca_requests_path(login: @superadmin.name, api_key: api_key.key), as: :json

        assert_response 302
      end

      should "not render for admins" do
        get_auth dmca_requests_path, @admin, reauthenticate: true
        assert_response 403
      end
    end

    context "show action" do
      should "render for the superadmin" do
        get_auth dmca_request_path(@dmca_request), @superadmin, reauthenticate: true

        assert_response :success
        assert_select "a[href='https://example.com/1.html']"
        assert_select "a[href^='javascript']", count: 0
      end

      should "link to the posts in the request" do
        post = create(:post)
        Danbooru.config.stubs(:canonical_url).returns("https://booru.example.com")
        dmca_request = create(:dmca_request, infringing_urls: "https://booru.example.com/posts/#{post.id}")
        get_auth dmca_request_path(dmca_request), @superadmin, reauthenticate: true

        assert_response :success
        assert_select "a[href='#{post_path(post)}']"
      end

      should "render for a request with purged personal info" do
        @dmca_request.update!(status: :handled, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day, updater: @superadmin)
        DmcaRequest.prune!
        get_auth dmca_request_path(@dmca_request), @superadmin, reauthenticate: true

        assert_response :success
        assert_select "a[href='https://example.com/1.html']"
      end

      should "not render for admins" do
        get_auth dmca_request_path(@dmca_request), @admin, reauthenticate: true
        assert_response 403
      end
    end

    context "update action" do
      should "allow the superadmin to mark a request as handled" do
        put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "handled" }}, reauthenticate: true

        assert_redirected_to dmca_requests_path
        assert_equal("handled", @dmca_request.reload.status)
        assert_equal("dmca_request_handled", ModAction.last.category)
        assert_equal(@superadmin, ModAction.last.creator)
        assert_equal(@dmca_request, ModAction.last.subject)
      end

      should "allow the superadmin to reject a request" do
        put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "rejected" }}, reauthenticate: true

        assert_redirected_to dmca_requests_path
        assert_equal("rejected", @dmca_request.reload.status)
        assert_equal("dmca_request_rejected", ModAction.last.category)
        assert_equal(@superadmin, ModAction.last.creator)
        assert_equal(@dmca_request, ModAction.last.subject)
      end

      should "not allow the superadmin to edit the contents of a request" do
        put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "handled", name: "Jane Doe" }}, reauthenticate: true

        assert_response 403
        assert_equal("John Doe", @dmca_request.reload.name)
        assert_equal("pending", @dmca_request.status)
      end

      should "not allow a request to be set back to pending" do
        @dmca_request.update!(status: :handled, updater: @superadmin)

        assert_no_difference("ModAction.count") do
          put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "pending" }}, reauthenticate: true
        end

        assert_equal("handled", @dmca_request.reload.status)
      end

      should "not log a mod action when the status does not change" do
        @dmca_request.update!(status: :handled, updater: @superadmin)

        assert_no_difference("ModAction.count") do
          put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "handled" }}, reauthenticate: true
        end
      end

      should "fail for an invalid status" do
        put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "bogus" }}, reauthenticate: true

        assert_redirected_to dmca_requests_path
        assert_equal("Status is not included in the list", flash[:notice])
        assert_equal("pending", @dmca_request.reload.status)
        assert_equal(0, ModAction.count)
      end

      should "require the superadmin to reauthenticate" do
        put_auth dmca_request_path(@dmca_request), @superadmin, params: { dmca_request: { status: "handled" }}

        assert_redirected_to confirm_password_session_path(url: dmca_request_path(@dmca_request))
        assert_equal("pending", @dmca_request.reload.status)
        assert_equal(0, ModAction.count)
      end

      should "not allow admins to update a request" do
        put_auth dmca_request_path(@dmca_request), @admin, params: { dmca_request: { status: "handled" }}, reauthenticate: true

        assert_response 403
        assert_equal("pending", @dmca_request.reload.status)
      end
    end

    context "the navbar" do
      should "show the number of pending requests to the superadmin" do
        get_auth posts_path, @superadmin

        assert_response :success
        assert_select "#nav-dmca .badge-blue", text: "1"
      end

      should "show the DMCA link to the superadmin when there are no pending requests" do
        @dmca_request.update!(status: :handled, updater: @superadmin)
        get_auth posts_path, @superadmin

        assert_response :success
        assert_select "#nav-dmca"
        assert_select "#nav-dmca .badge-blue", count: 0
      end

      should "not show the DMCA link to admins" do
        get_auth posts_path, @admin

        assert_response :success
        assert_select "#nav-dmca", count: 0
      end
    end

    context "the mod actions for a handled request" do
      setup do
        @dmca_request.update!(status: :handled, updater: @superadmin)
      end

      should "be visible to the superadmin" do
        get_auth mod_actions_path(search: { subject_type: "DmcaRequest", subject_id: @dmca_request.id }), @superadmin, as: :json

        assert_response :success
        assert_equal(["dmca_request_handled"], response.parsed_body.pluck("category"))

        get_auth mod_actions_path, @superadmin
        assert_response :success

        get_auth mod_action_path(ModAction.last), @superadmin, as: :json
        assert_response :success
      end

      should "be hidden from admins" do
        get_auth mod_actions_path, @admin, as: :json

        assert_response :success
        assert_equal(0, response.parsed_body.count)

        get_auth mod_action_path(ModAction.last), @admin, as: :json
        assert_response 403

        get_auth report_path("mod_actions", format: :json, search: { category: "dmca_request_handled" }), @admin
        assert_equal([0], response.parsed_body.pluck("mod_actions"))

        get_auth user_actions_path(search: { model_type: "ModAction" }), @admin, as: :json
        assert_equal(0, response.parsed_body.count)
      end
    end
  end
end
