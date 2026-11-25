require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  context "The application controller" do
    should "handle a rack request without a remote ip" do
      env = Rack::MockRequest.env_for("/", "HTTP_HOST" => "test.host")
      env.delete("REMOTE_ADDR")

      status, = Rails.application.call(env)

      assert_equal(200, status)
    end

    should "return 406 Not Acceptable for a bad file extension" do
      get posts_path, params: { format: :jpg }
      assert_response 406

      get posts_path, params: { format: :blah }
      assert_response 406
    end

    should "return 400 Bad Request for a GET request with a body" do
      get root_path, headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json" }, env: { RAW_POST_DATA: "tags=touhou" }

      assert_response 400
      assert_equal("ApplicationController::RequestBodyNotAllowedError", response.parsed_body["error"])
      assert_equal("Request body not allowed for GET request", response.parsed_body["message"])
    end

    should "return 200 OK for a POST request overridden to be a GET request" do
      post root_path, headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json", "X-Http-Method-Override": "GET" }, env: { RAW_POST_DATA: "tags=touhou" }

      assert_response 200
    end

    should "return 422 for search params with the wrong type" do
      get artists_path(search: { is_deleted: "abc" }), as: :json
      assert_response 422

      get artists_path(search: { name: { x: 1 }}), as: :json
      assert_response 422
    end

    should "return 422 for an invalid regex in a search param" do
      get artist_commentaries_path(search: { original_description_regex: "[A-Za-z]![[:word:}]" }), as: :json
      assert_response 422
      assert_equal("Invalid regular expression: brackets [] not balanced", response.parsed_body["message"])
    end

    should "return 400 for a missing or invalid required param" do
      get_auth new_forum_post_path(post_id: ["1"], format: :json), create(:user)
      assert_response 400
      assert_equal("param is missing or the value is empty or invalid: post_id", response.parsed_body["message"])
    end

    should "return 400 for a page or limit param that isn't a string or integer" do
      get posts_path(limit: ["1"]), as: :json
      assert_response 400

      get artists_path(limit: { a: 1 }), as: :json
      assert_response 400

      get autocomplete_index_path(limit: ["1"], search: { type: "tag_query", query: "a" }), as: :json
      assert_response 400

      get related_tag_path(limit: ["1"], search: { query: "a" }), as: :json
      assert_response 400

      get tags_path(page: ["1"]), as: :json
      assert_response 400

      post tags_path, params: { limit: true }, headers: { "X-Http-Method-Override": "GET" }, as: :json
      assert_response 400
      assert_equal("limit parameter must be a string or an integer", response.parsed_body["message"])

      post tags_path, params: { page: false }, headers: { "X-Http-Method-Override": "GET" }, as: :json
      assert_response 400

      post tags_path, params: { limit: 1.5 }, headers: { "X-Http-Method-Override": "GET" }, as: :json
      assert_response 400

      post tags_path, params: { limit: nil, page: nil }, headers: { "X-Http-Method-Override": "GET" }, as: :json
      assert_response 200

      post tags_path, params: { limit: 1, page: 1 }, headers: { "X-Http-Method-Override": "GET" }, as: :json
      assert_response 200
    end

    should "return 400 for model params that aren't a hash" do
      user = create(:user, created_at: 1.month.ago)

      post_auth comments_path, user, params: { comment: "x" }
      assert_response 400

      post_auth pools_path, user, params: { pool: ["x"] }, as: :json
      assert_response 400

      post_auth api_keys_path, user, params: { api_key: "x" }, as: :json, reauthenticate: true
      assert_response 400

      put_auth create_or_update_artist_commentaries_path, user, params: { artist_commentary: "x" }, as: :json
      assert_response 400

      post_auth post_disapprovals_path, create(:approver), params: { post_disapproval: ["x"] }, as: :json
      assert_response 400

      post dmca_path, params: { dmca: "x" }, as: :json
      assert_response 400

      post_auth upgrade_upgrade_codes_path, user, params: { upgrade_code: "x" }, as: :json
      assert_response 400
    end

    context "for parameters containing null bytes" do
      should "return 400 for GET requests" do
        get posts_path(tags: "a\0b"), as: :json
        assert_response 400

        get tags_path(search: { name: "a\0" }), as: :json
        assert_response 400

        get tags_path(search: { name: ["a", "b\0"] }), as: :json
        assert_response 400

        get posts_path("a\0b" => "c"), as: :json
        assert_response 400
      end

      should "return 400 for POST requests" do
        post_auth comments_path, create(:user), params: { comment: { post_id: create(:post).id, body: "a\0b" }}, as: :json
        assert_response 400
      end

      should "return 400 for API key parameters" do
        get posts_path(login: "a\0b", api_key: "x"), as: :json
        assert_response 400
      end

      should "return 401 for basic auth credentials" do
        get posts_path, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("a\0b", "x") }, as: :json
        assert_response 401
      end
    end

    should "not fail for the only param on pages without a model when there are no results" do
      get autocomplete_index_path(search: { type: "tag_query", query: "zzzznonexistent" }, only: "id"), as: :json
      assert_response :success
    end

    should "return 422 for an oversized param on a GET request" do
      get posts_path(foo: "a" * (ApplicationController::MAX_GET_PARAMETER_LENGTH + 1)), as: :json

      assert_response 422
      assert_equal("ApplicationController::ParamTooLongError", response.parsed_body["error"])
    end

    should "return 422 for an oversized param on a POST request overridden to GET" do
      post posts_path(format: :json), params: { _method: "GET", foo: "a" * (ApplicationController::MAX_GET_PARAMETER_LENGTH + 1) }

      assert_response 422
      assert_equal("ApplicationController::ParamTooLongError", response.parsed_body["error"])
    end

    should "not restrict parameter size for normal POST requests" do
      post_auth wiki_pages_path, create(:user), params: { wiki_page: attributes_for(:wiki_page, body: "a" * (ApplicationController::MAX_GET_PARAMETER_LENGTH + 1)) }

      assert_redirected_to wiki_page_path(WikiPage.last)
    end

    context "on a request with an unparseable JSON body" do
      setup do
        @user = create(:user)
        @api_key = create(:api_key, user: @user)
        @headers = { HTTP_AUTHORIZATION: "Basic #{::Base64.strict_encode64("#{@user.name}:#{@api_key.key}")}" }
        @env = { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "*/*" }
      end

      should "return 400 Bad Request in JSON for a .json URL" do
        post posts_path(format: :json), params: "tags=touhou&_method=get", headers: @headers, env: @env

        assert_response 400
        assert_equal("ActionDispatch::Http::Parameters::ParseError", response.parsed_body["error"])
      end

      should "return 400 Bad Request in JSON for a .json URL for an anonymous user" do
        post posts_path(format: :json), params: "tags=touhou&_method=get", env: @env

        assert_response 400
        assert_equal("ActionDispatch::Http::Parameters::ParseError", response.parsed_body["error"])
      end

      should "return 400 Bad Request in HTML for an HTML URL" do
        post posts_path, params: "tags=touhou&_method=get", headers: @headers, env: @env

        assert_response 400
        assert_match(/Error occurred while parsing request parameters/, response.body)
      end
    end

    should "return 404 Not Found for an unsupported method on the root path" do
      post root_path
      assert_response 404

      put root_path
      assert_response 404

      patch root_path
      assert_response 404

      delete root_path
      assert_response 404
    end

    context "for a multipart form" do
      setup do
        @user = create(:user)
        login_as(@user)
      end

      should "treat fields as UTF-8 regardless of their charset" do
        post wiki_pages_path, headers: { "Content-Type": "multipart/form-data; boundary=xyz" }, params: multipart_body("wiki_page[title]" => ["text/plain; charset=UTF-16LE", "abcd"], "wiki_page[body]" => ["text/plain; charset=Shift_JIS", "あ"])

        assert_redirected_to wiki_page_path(WikiPage.last)
        assert_equal("abcd", WikiPage.last.title)
        assert_equal("あ", WikiPage.last.body)
        assert_equal(Encoding::UTF_8, WikiPage.last.body.encoding)
      end

      should "return 400 for fields that aren't valid UTF-8" do
        assert_no_difference("WikiPage.count") do
          post wiki_pages_path(format: :json), headers: { "Content-Type": "multipart/form-data; boundary=xyz" }, params: multipart_body("wiki_page[title]" => ["text/plain", "test"], "wiki_page[body]" => ["text/plain; charset=Shift_JIS", "あ".encode("Shift_JIS")])
        end

        assert_response 400
      end

      should "return 400 for fields containing a NUL byte" do
        assert_no_difference("WikiPage.count") do
          post wiki_pages_path(format: :json), headers: { "Content-Type": "multipart/form-data; boundary=xyz" }, params: multipart_body("wiki_page[title]" => ["text/plain", "test"], "wiki_page[body]" => ["text/plain", "a\0b"])
        end

        assert_response 400
      end
    end

    context "on a RecordNotFound error" do
      should "return 404 Not Found even with a bad file extension" do
        get post_path("bad.json")
        assert_response 404

        get post_path("bad.jpg")
        assert_response 404

        get post_path("bad.blah")
        assert_response 404
      end
    end

    context "on a PaginationError" do
      should "return 410 Gone even with a bad file extension" do
        get posts_path(page: 999_999_999), as: :json
        assert_response 410

        get posts_path(page: 999_999_999), as: :jpg
        assert_response 410

        get posts_path(page: 999_999_999), as: :blah
        assert_response 410
      end
    end

    context "on an unexpected error" do
      setup do
        User.stubs(:find).raises(NoMethodError.new("pwned"))
        @user = create(:user)
      end

      should "not return the error message in the HTML response" do
        get user_path(@user)

        assert_response 500
        assert_match(/NoMethodError/, response.body.to_s)
        assert_no_match(/pwned/, response.body.to_s)
      end

      should "not return the error message in the JSON response" do
        get user_path(@user, format: :json)

        assert_response 500
        assert_match(/NoMethodError/, response.body.to_s)
        assert_no_match(/pwned/, response.body.to_s)
      end

      should "not return the error message in the XML response" do
        get user_path(@user, format: :xml)

        assert_response 500
        assert_match(/NoMethodError/, response.body.to_s)
        assert_no_match(/pwned/, response.body.to_s)
      end

      should "not return the error message in the JS response" do
        get user_path(@user, format: :js)

        assert_response 500
        assert_match(/NoMethodError/, response.body.to_s)
        assert_no_match(/pwned/, response.body.to_s)
      end
    end

    context "on a cross-origin request for a .js response" do
      setup do
        login_as(create(:user))
        ActionController::Base.allow_forgery_protection = true
      end

      teardown do
        ActionController::Base.allow_forgery_protection = false
      end

      should "return a 403 error without rendering the Javascript" do
        get new_comment_path(format: :js)

        assert_response 403
        assert_equal("text/html", response.media_type)
        assert_match(/requested protected JavaScript/, response.body)
        assert_no_match(/Danbooru\.Notice/, response.body)
      end

      should "not cache the error response when the page would have been publicly cached" do
        get related_tag_path(format: :js, query: "touhou")

        assert_response 403
        assert_equal("text/html", response.media_type)
        assert_no_match(/public|max-age/, response.headers["Cache-Control"].to_s)
      end

      should "allow same-origin xhr requests" do
        get new_comment_path(format: :js), xhr: true

        assert_response :success
      end
    end

    context "when a user has an invalid username" do
      should "redirect to the name change page" do
        @user = build(:user, name: "foo__bar")
        @user.save!(validate: false)

        get_auth posts_path, @user
        assert_redirected_to change_name_user_path(@user)
      end
    end

    context "on api authentication" do
      setup do
        @user = create(:user, password: "password")
        @api_key = create(:api_key, user: @user)

        ActionController::Base.allow_forgery_protection = true
      end

      teardown do
        ActionController::Base.allow_forgery_protection = false
      end

      context "using http basic auth" do
        should "succeed for api key matches" do
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get profile_path, as: :json, headers: { HTTP_AUTHORIZATION: basic_auth_string }

          assert_response :success
          assert_equal(@user.id, response.parsed_body["id"])
          assert_equal(1, @api_key.reload.uses)
          assert_not_nil(@api_key.reload.last_used_at)
        end

        should "succeed when the user has multiple api keys" do
          @api_key2 = create(:api_key, user: @user)
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key2.key}")}"
          get profile_path, as: :json, headers: { HTTP_AUTHORIZATION: basic_auth_string }

          assert_response :success
          assert_equal(@user.id, response.parsed_body["id"])
          assert_equal(1, @api_key2.reload.uses)
          assert_not_nil(@api_key2.reload.last_used_at)
        end

        should "fail when the request has a logged in session cookie" do
          ActionController::Base.allow_forgery_protection = false
          login_as(@user)
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get profile_path, as: :json, headers: { HTTP_AUTHORIZATION: basic_auth_string }

          assert_response 401
          assert_equal(0, @api_key.reload.uses)
        end

        should "fail for HTML requests" do
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get edit_user_path(@user), headers: { HTTP_AUTHORIZATION: basic_auth_string }

          assert_response 401
          assert_equal(0, @api_key.reload.uses)
        end

        should "fail for api key mismatches" do
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:badpassword")}"
          get profile_path, as: :json, headers: { HTTP_AUTHORIZATION: basic_auth_string }
          assert_response 401
        end

        should "fail for a deleted user" do
          @user.update!(is_deleted: true)
          basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
          get profile_path, as: :json, headers: { HTTP_AUTHORIZATION: basic_auth_string }

          assert_response 401
        end

        should "succeed for non-GET requests without a CSRF token" do
          assert_changes -> { @user.reload.enable_safe_mode }, from: false, to: true do
            basic_auth_string = "Basic #{::Base64.encode64("#{@user.name}:#{@api_key.key}")}"
            put user_path(@user), headers: { HTTP_AUTHORIZATION: basic_auth_string }, params: { user: { enable_safe_mode: "true" }}, as: :json
            assert_response :success
          end
        end
      end

      context "using the api_key parameter" do
        should "succeed for api key matches" do
          get profile_path(login: @user.name, api_key: @api_key.key), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["id"])
          assert_equal(1, @api_key.reload.uses)
          assert_not_nil(@api_key.reload.last_used_at)
        end

        should "succeed when the user has multiple api keys" do
          @api_key2 = create(:api_key, user: @user)
          get profile_path(login: @user.name, api_key: @api_key2.key), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["id"])
          assert_equal(1, @api_key2.reload.uses)
          assert_not_nil(@api_key2.reload.last_used_at)
        end

        should "fail when the request has a logged in session cookie" do
          ActionController::Base.allow_forgery_protection = false
          login_as(create(:user))
          get profile_path(login: @user.name, api_key: @api_key.key), as: :json

          assert_response 401
          assert_equal(0, @api_key.reload.uses)
        end

        should "succeed when the request has a logged out session cookie" do
          ActionController::Base.allow_forgery_protection = false
          login_as(@user)
          delete session_path
          get profile_path(login: @user.name, api_key: @api_key.key), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["id"])
        end

        should "fail for HTML requests" do
          get edit_user_path(@user), params: { login: @user.name, api_key: @api_key.key }
          assert_response 401

          get edit_user_path(@user, format: :js), params: { login: @user.name, api_key: @api_key.key }
          assert_response 401

          assert_equal(0, @api_key.reload.uses)
        end

        should "fail for api key mismatches" do
          get profile_path(login: @user.name), as: :json
          assert_response 401

          get profile_path(api_key: @api_key.key), as: :json
          assert_response 401

          get profile_path(login: @user.name, api_key: "bad"), as: :json
          assert_response 401
        end

        should "fail for a blank API key" do
          get profile_path(login: ""), as: :json
          assert_response 401

          get profile_path(api_key: ""), as: :json
          assert_response 401
        end

        should "fail for a deleted user" do
          @user.update!(is_deleted: true)
          get profile_path(login: @user.name, api_key: @api_key.key), as: :json

          assert_response 401
        end

        should "succeed for non-GET requests without a CSRF token" do
          assert_changes -> { @user.reload.enable_safe_mode }, from: false, to: true do
            put user_path(@user, login: @user.name, api_key: @api_key.key), params: { user: { enable_safe_mode: "true" }}, as: :json
            assert_response :success
          end
        end
      end

      context "for an API key with restrictions" do
        should "restrict requests to the permitted IP addresses" do
          @api_key = create(:api_key, permitted_ip_addresses: ["1.2.3.4", "2.0.0.1/24", "2600::1/64"])

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("1.2.3.4")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response :success

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("2.0.0.42")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response :success

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("2600::1234:0:0:1")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response :success

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("127.0.0.2")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response 403

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("2.0.1.0")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response 403

          ActionDispatch::Request.any_instance.stubs(:remote_ip).returns("2600:dead:beef::1")
          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response 403

          assert_equal(6, @api_key.reload.uses)
          assert_equal("2600:dead:beef::1", @api_key.reload.last_ip_address.to_s)
          assert_not_nil(@api_key.reload.last_used_at)
        end

        should "restrict requests to the permitted endpoints" do
          @post = create(:post)
          @api_key = create(:api_key, permissions: ["posts:index", "posts:show"])

          get posts_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response :success

          get post_path(@post, login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response :success

          get tags_path(login: @api_key.user.name, api_key: @api_key.key), as: :json
          assert_response 403

          put post_path(@post, login: @api_key.user.name, api_key: @api_key.key), params: { post: { rating: "s" }}, as: :json
          assert_response 403

          assert_equal(4, @api_key.reload.uses)
          assert_equal("127.0.0.1", @api_key.reload.last_ip_address.to_s)
          assert_not_nil(@api_key.reload.last_used_at)
        end
      end

      context "with cookie-based authentication" do
        should "not allow non-GET requests without a CSRF token" do
          # get the csrf token from the login page so we can login
          get new_session_path
          assert_response :success
          token = css_select("form input[name=authenticity_token]").first["value"]

          # login
          post session_path, params: { authenticity_token: token, session: { name: @user.name, password: "password" }}
          assert_redirected_to root_path

          # try to submit a form with cookies but without the csrf token
          put user_path(@user), headers: { HTTP_COOKIE: headers["Set-Cookie"] }, params: { user: { enable_safe_mode: "true" }}
          assert_response 403
          assert_equal("Error: Can't verify CSRF token authenticity.", css_select("p").first.content)
          assert_equal(false, @user.reload.enable_safe_mode)
        end
      end
    end

    context "when the session cookie domain is set" do
      setup do
        Danbooru.config.stubs(:session_cookie_domain).returns("example.com")
      end

      should "delete the host-only session cookie if the request has duplicate session cookies" do
        get posts_path, headers: { HTTP_COOKIE: "_danbooru2_session=a; _danbooru2_session=b" }

        assert_response :success
        deleted_cookies = Array(response.headers["Set-Cookie"]).grep(/\A_danbooru2_session=;/)
        assert_equal(1, deleted_cookies.size)
        assert_match(%r{\A_danbooru2_session=; path=/; max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT\z}, deleted_cookies.first)
      end

      should "not delete the session cookie if the request has a single session cookie" do
        get posts_path, headers: { HTTP_COOKIE: "_danbooru2_session=a" }

        assert_response :success
        assert_empty(Array(response.headers["Set-Cookie"]).grep(/max-age=0/))
      end
    end

    context "on session cookie authentication" do
      setup do
        @user = create(:user, password: "password")
        login_as(@user)
      end

      should "succeed" do
        get profile_path

        assert_response :success
      end

      should "fail for a deleted user" do
        @user.update!(is_deleted: true)

        get profile_path

        assert_redirected_to login_path(url: "/profile")
        assert_nil(session[:user_id])
        assert_equal(true, @user.user_events.exists?(category: :logout))
      end

      should "fail for a session that was logged out" do
        @user.login_sessions.last.update!(status: :logged_out)

        get profile_path

        assert_redirected_to login_path(url: "/profile")
        assert_nil(session[:user_id])
        assert_nil(session[:login_id])
      end

      should "fail for a session that was revoked" do
        @user.login_sessions.last.revoke!

        get profile_path

        assert_redirected_to login_path(url: "/profile")
        assert_nil(session[:user_id])
        assert_nil(session[:login_id])
        assert_equal(false, @user.user_events.logout.exists?)
        assert_equal(true, @user.login_sessions.last.revoked?)
      end

      should "fail for a session belonging to a different user" do
        @user.login_sessions.last.update!(user: create(:user))

        get profile_path

        assert_redirected_to login_path(url: "/profile")
        assert_nil(session[:user_id])
        assert_nil(session[:login_id])
      end
    end

    context "from a fully IP banned address" do
      setup do
        @ip_ban = create(:ip_ban, category: :full, ip_addr: "1.2.3.4")
        @post = create(:post)
      end

      should "block write requests from members" do
        post_auth favorites_path(post_id: @post.id), create(:user), as: :json, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_response 403
        assert_equal(0, @post.reload.fav_count)
        assert_equal(1, @ip_ban.reload.hit_count)
      end

      should "not block write requests from moderators" do
        post_auth favorites_path(post_id: @post.id), create(:moderator_user), as: :json, headers: { REMOTE_ADDR: "1.2.3.4" }

        assert_response :success
        assert_equal(1, @post.reload.fav_count)
        assert_equal(0, @ip_ban.reload.hit_count)
      end
    end

    context "accessing an unauthorized page" do
      should "render the access denied page" do
        get news_updates_path

        assert_response 403
        assert_select "h1", /Access Denied/
      end

      should "render a json response for json requests" do
        get news_updates_path(format: :json)

        assert_response 403
        assert_equal "application/json", response.media_type
        assert_equal "Access denied", response.parsed_body["message"]
      end
    end

    context "when the URL contains reserved url_for options" do
      setup do
        @user = create(:user)
        as(@user) { create(:wiki_page) }
        create_list(:tag, 3)
        @query = "protocol=javascript&host=%250aalert(1)%252f%252f&script_name=javascript:alert(1)%2f%2f&port=1337"
      end

      should "not let them change the URLs of links on the page" do
        ["/tags?limit=1&#{@query}", "/wiki_page_versions?search[title]=x&#{@query}", "/posts?#{@query}"].each do |path|
          get_auth path, @user

          assert_response :success
          hrefs = css_select("a[href], link[rel=canonical]").pluck("href")
          assert_empty(hrefs.grep(/alert|1337/), "#{path} contains an unsafe link")
        end
      end

      should "not let them change the redirect URL when removing blank search params" do
        get "/tags?search[name]=&#{@query}"

        assert_response :redirect
        assert_match(%r{\Ahttp://www\.example\.com/tags\?}, response.location)
      end
    end

    context "when the api limit is exceeded" do
      should "fail with a 429 error" do
        user = create(:user)
        post = create(:post, rating: "s")
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "posts:update", key: user.cache_key, limited: true)

        put_auth post_path(post), user, params: { post: { rating: "e" }}

        assert_response 429
        assert_equal("s", post.reload.rating)
      end
    end

    context "the per-session rate limit" do
      setup do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
      end

      should "not be used for requests without a session cookie" do
        post session_path, params: { session: { name: "nobody", password: "wrong" }}

        assert_equal(["ip/127.0.0.1"], JSON.parse(response.headers["X-Rate-Limit"])["limits"].keys)
        assert_equal(false, RateLimit.where_like(:key, "session/*").exists?)
      end

      should "be used for requests with a session cookie" do
        post session_path, params: { session: { name: "nobody", password: "wrong" }}
        post session_path, params: { session: { name: "nobody", password: "wrong" }}

        assert_equal(["ip/127.0.0.1", "session/#{session.id}"], JSON.parse(response.headers["X-Rate-Limit"])["limits"].keys.sort)
      end
    end
  end

  context "all index methods" do
    should "support searching by the id attribute" do
      tags = create_list(:tag, 2, post_count: 42)
      get tags_path(format: :json, search: { id: tags.first.id })

      assert_response :success
      assert_equal(1, response.parsed_body.size)
      assert_equal(tags.first.id, response.parsed_body.first.fetch("id"))
    end

    should "support ordering by search[order]=custom" do
      tags = create_list(:tag, 2, post_count: 42)
      get tags_path(search: { id: "#{tags[0].id},#{tags[1].id}", order: "custom" }), as: :json

      assert_response :success
      assert_equal(tags.pluck(:id), response.parsed_body.pluck("id"))
    end

    should "return nothing if the search[order]=custom param isn't accompanied by search[id]" do
      create_list(:tag, 2, post_count: 42)
      get tags_path(search: { order: "custom" }), as: :json

      assert_response :success
      assert_equal(0, response.parsed_body.size)
    end

    should "return nothing if the search[order]=custom param isn't accompanied by a valid search[id]" do
      create_list(:tag, 2, post_count: 42)
      get tags_path(search: { id: ">1", order: "custom" }), as: :json

      assert_response :success
      assert_equal(0, response.parsed_body.size)
    end

    should "work if the search[order]=custom param is used with a single id" do
      tags = create_list(:tag, 2, post_count: 42)
      get tags_path(search: { id: tags[0].id, order: "custom" }), as: :json

      assert_response :success
      assert_equal([tags[0].id], response.parsed_body.pluck("id"))
    end

    should "remove blank `search` params from the URL" do
      get tags_path(search: { name: "touhou", blah: "" }), as: :json

      assert_redirected_to tags_path(search: { name: "touhou" })
    end

    should "ignore invalid `search` params" do
      get tags_path(search: "foo"), as: :json
      assert_response :success

      get tags_path("search[]": "foo"), as: :json
      assert_response :success
    end

    should "support the expiry parameter" do
      get posts_path(expiry: "1"), as: :json

      assert_response :success
      assert_equal("max-age=#{1.day}, private", response.headers["Cache-Control"])
    end

    should "support the expires_in parameter" do
      get posts_path(expires_in: "5min"), as: :json

      assert_response :success
      assert_equal("max-age=#{5.minutes}, private", response.headers["Cache-Control"])
    end

    should "support the only parameter" do
      create(:post)
      get posts_path(only: "id,rating,score"), as: :json

      assert_response :success
      assert_equal(%w[id rating score].sort, response.parsed_body.first.keys.sort)
    end

    should "return the correct root element name for empty xml responses" do
      get tags_path, as: :xml

      assert_response :success
      assert_equal("tags", response.parsed_body.root.name)
      assert_equal(0, response.parsed_body.root.children.size)
    end

    context "for the only= param" do
      setup do
        @post = create(:post)
      end

      should "support simple fields" do
        get posts_path(only: "id,md5,rating,score", limit: 1), as: :json

        assert_response :success
        assert_equal(%w[id md5 rating score].sort, response.parsed_body.sole.keys.sort)
      end

      should "ignore nil nested includes" do
        @post = create(:post, parent: nil)

        get posts_path(only: "id,parent[id]", limit: 1), as: :json

        assert_response :success
        assert_equal(["id"], response.parsed_body.sole.keys)
      end

      should "support API attributes" do
        get posts_path(only: "id,file_url", limit: 1), as: :json

        assert_response :success
        assert_equal(%w[id file_url].sort, response.parsed_body.first.keys.sort)
      end

      should "ignore unknown fields" do
        get posts_path(only: "id,bogus", limit: 1), as: :json

        assert_response :success
        assert_equal(%w[id], response.parsed_body.sole.keys)
      end

      should "support blank field lists" do
        get posts_path(only: "", limit: 1), as: :json

        assert_response :success
        assert_equal([], response.parsed_body.sole.keys)
      end

      should "return an error for field lists that are too long" do
        get posts_path(only: "id," * 500, limit: 1), as: :json

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "return a param length error for field lists that are too long using a POST request with _method=GET" do
        post posts_path(format: :json), params: { _method: "GET", limit: 1, only: "id," * ParameterBuilder::MAX_LENGTH }, as: :url_encoded

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "return an error for field lists that are nested too deeply" do
        get posts_path(only: "id,#{"parent[" * 9}id#{"]" * 9}", limit: 1), as: :json

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "return an error response for unbalanced opening brackets" do
        get posts_path(only: "id,comments[body", limit: 1), as: :json

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "return an error response for unbalanced closing brackets" do
        get posts_path(only: "id,comments[body]]", limit: 1), as: :json

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "return an error when including too many records" do
        create_list(:comment, 3, post: @post)

        stub_const(ParameterBuilder, :MAX_INCLUDED_RECORDS, 3) do
          get posts_path(tags: "id:#{@post.id}", only: "id,comments[creator]", limit: 1), as: :json
        end

        assert_response 422
        assert_equal("ParameterBuilder::Error", response.parsed_body["error"])
      end

      should "allow including records up to the limit" do
        create_list(:comment, 3, post: @post)

        stub_const(ParameterBuilder, :MAX_INCLUDED_RECORDS, 3) do
          get posts_path(tags: "id:#{@post.id}", only: "id,comments", limit: 1), as: :json
        end

        assert_response :success
        assert_equal(3, response.parsed_body.sole["comments"].size)
      end

      should "support POST requests overridden to GET" do
        post posts_path(format: :json), params: { _method: "GET", limit: 1, only: "id,rating,score" }, as: :url_encoded

        assert_response :success
        assert_equal(%w[id rating score].sort, response.parsed_body.sole.keys.sort)
      end

      should "support nested fields" do
        create(:comment, post: @post)

        get posts_path(only: "id,rating,comments[body,creator[name]],notes", limit: 1), as: :json

        assert_response :success
        assert_equal(%w[id rating comments notes].sort, response.parsed_body.sole.keys.sort)

        comments = response.parsed_body.sole["comments"]
        assert_equal(%w[body creator].sort, comments.sole.keys.sort)
        assert_equal(%w[name].sort, comments.sole["creator"].keys)
      end

      should "overwrite duplicate nested includes" do
        create_list(:comment, 2, post: @post)

        get posts_path(only: "id,comments[body,creator[name]],comments[creator[id]]", limit: 1), as: :json

        assert_response :success
        comments = response.parsed_body.sole["comments"]
        assert_equal(2, comments.size)
        assert_equal(%w[creator].sort, comments.first.keys.sort)
        assert_equal(%w[id].sort, comments.first["creator"].keys.sort)
      end

      should "avoid recursive has_many expansion for nested children includes" do
        parent = create(:post)
        child = create(:post, parent: parent)
        create(:post, parent: child)

        get posts_path(tags: "id:#{parent.id}", only: "id,children[id,children[id,children[id]]]", limit: 1), as: :json
        assert_response :success

        post = response.parsed_body.sole
        assert_equal(parent.id, post["id"])
        assert_equal(%w[children id], post.keys.sort)
        assert_equal(["id"], post["children"].first.keys)
      end

      should "work for nested includes of empty has_many associations" do
        post = create(:post)

        get posts_path(tags: "id:#{post.id}", only: "id,parent[id],children[id]", limit: 1), as: :json
        assert_response :success
        assert_equal({ "id" => post.id, "children" => [] }, response.parsed_body.sole)
      end

      should "not include associations whose foreign key is hidden" do
        create(:comment, post: @post, is_deleted: true)
        create(:post_disapproval, post: create(:post, is_pending: true))

        get comments_path(group_by: :comment, only: "id,creator[name],updater"), as: :json
        assert_response :success
        assert_equal(%w[id], response.parsed_body.sole.keys)

        get_auth post_disapprovals_path(only: "id,user[name],post[id]"), create(:user), as: :json
        assert_response :success
        assert_equal(%w[id post], response.parsed_body.sole.keys.sort)
      end

      should "not run visibility queries for included models without visibility restrictions" do
        create(:comment, post: @post)
        count_queries = lambda do
          count = 0
          ActiveSupport::Notifications.subscribed(->(*, payload) { count += 1 if payload[:sql].start_with?("SELECT") }, "sql.active_record") do
            get posts_path(only: "id,uploader[name],comments[body]", limit: 1), as: :json
          end
          count
        end

        count_queries.call # warm up caches
        queries = count_queries.call
        ApplicationRecord.stubs(:hide_invisible_includes!)
        assert_equal(count_queries.call, queries)
      end

      should "not include hidden methods when only some nested records hide them" do
        visible_child = create(:post, parent: @post)
        banned_child = create(:post, parent: @post, is_banned: true)

        get post_path(@post, only: "children[id,file_url]"), as: :json
        assert_response :success

        children = response.parsed_body["children"].index_by { it["id"] }
        assert_equal(%w[file_url id], children[visible_child.id].keys.sort)
        assert_equal(%w[id], children[banned_child.id].keys)
      end

      should "not include hidden associations when only some nested records hide them" do
        create(:comment, post: @post, is_deleted: false)
        create(:comment, post: @post, is_deleted: true)

        get posts_path(only: "id,comments[is_deleted,creator[name]]", limit: 1), as: :json
        assert_response :success

        comments = response.parsed_body.sole["comments"].index_by { it["is_deleted"] }
        assert_equal(%w[creator is_deleted], comments[false].keys.sort)
        assert_equal(%w[is_deleted], comments[true].keys)
      end
    end
  end

  # @param fields [Hash<String, (String, String)>] A hash of field names to [content type, value] pairs.
  # @return [String] A multipart/form-data body with the boundary "xyz".
  def multipart_body(fields)
    parts = fields.map do |name, (content_type, value)|
      "--xyz\r\nContent-Disposition: form-data; name=\"#{name}\"\r\nContent-Type: #{content_type}\r\n\r\n".b + value.b + "\r\n".b
    end

    parts.join.b + "--xyz--\r\n".b
  end
end
