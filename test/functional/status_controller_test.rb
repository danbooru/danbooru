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
