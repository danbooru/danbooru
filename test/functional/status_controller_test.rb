require "test_helper"

class StatusControllerTest < ActionDispatch::IntegrationTest
  context "The status controller" do
    should "work for a html response" do
      get status_path
      assert_response :success
    end

    should "work for a json response" do
      get status_path(format: :json)
      assert_response :success
    end

    should "work for an xml response" do
      get status_path(format: :xml)
      assert_response :success
    end

    should "work for a header containing UTF-8 characters" do
      get status_path, headers: { "User-Agent": "Portimão".dup.force_encoding("ASCII-8BIT") }
      assert_response :success
    end

    should "work for a header containing invalid UTF-8 characters" do
      get status_path, headers: { "User-Agent": "Portim\xE3o".dup.force_encoding("ASCII-8BIT") }
      assert_response :success
    end

    should "work when the database is down" do
      without_database do
        get status_path
        assert_response :success
      end
    end

    should "hide sensitive details from non-owners" do
      get_auth status_path(format: :json), create(:admin_user)

      assert_response :success
      assert_equal(%w[docker_image_build_date danbooru_version], response.parsed_body["version"].keys)
      assert_equal(%w[up active_connections], response.parsed_body["postgres"].keys)
      assert_equal(%w[up used_memory], response.parsed_body["redis"].keys)
      assert_not(response.parsed_body["server"].key?("kernel_version"))
    end

    should "show sensitive details to the owner" do
      get_auth status_path(format: :json), create(:owner_user)

      assert_response :success
      assert(response.parsed_body["version"].key?("ruby_version"))
      assert(response.parsed_body["version"].key?("postgres_version"))
      assert(response.parsed_body["postgres"].key?("connection_stats"))
      assert(response.parsed_body["postgres"].key?("error"))
      assert(response.parsed_body["redis"].key?("info"))
      assert(response.parsed_body["server"].key?("kernel_version"))
    end

    should "hide sensitive details from non-owners in the html response" do
      get_auth status_path, create(:admin_user)

      assert_response :success
      assert_select "th", text: "Ruby Version", count: 0
    end

    should "show sensitive details to the owner in the html response" do
      get_auth status_path, create(:owner_user)

      assert_response :success
      assert_select "th", text: "Ruby Version"
    end

    should "not show the database error when the database is down" do
      without_database do
        get status_path
        assert_response :success
        assert_select "#c-status", text: /Error:/, count: 0
      end
    end

    should "be rate limited" do
      user = create(:user)
      Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
      create(:rate_limit, action: "status:show", key: user.cache_key, limited: true)

      get_auth status_path(format: :json), user

      assert_response 429
    end

    should "not be rate limited when the database is down" do
      Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
      RateLimiter.expects(:build).never

      without_database do
        get status_path
        assert_response :success
      end
    end
  end
end
