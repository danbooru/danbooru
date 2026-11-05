require "test_helper"

class RelatedTagsControllerTest < ActionDispatch::IntegrationTest
  context "The related tags controller" do
    setup do
      as(create(:user)) { create(:post, tag_string: "copy:touhou") }
    end

    context "show action" do
      should "work" do
        get related_tag_path, params: { query: "touhou" }
        assert_response :success
      end

      should "work for .json responses" do
        get related_tag_path(format: :json), params: { query: "touhou" }
        assert_response :success
      end

      should "work for .js responses for copyright tags without a wiki" do
        get related_tag_path(format: :js), params: { query: "touhou" }, xhr: true
        assert_response :success
      end

      should "work for .js responses for character tags without a wiki" do
        create(:tag, name: "chen", category: TagCategory::CHARACTER)

        get related_tag_path(format: :js), params: { query: "chen" }, xhr: true
        assert_response :success
      end

      should "work for .js responses for character tags with a wiki" do
        create(:tag, name: "chen", category: TagCategory::CHARACTER)
        create(:wiki_page, title: "chen", body: "[[touhou]]")

        get related_tag_path(format: :js), params: { query: "chen" }, xhr: true
        assert_response :success
      end

      should "return a 422 error for searches with too many tags" do
        get related_tag_path(format: :json), params: { query: "aaa bbb ccc" }
        assert_response 422
      end

      should "cache .json responses" do
        get related_tag_path(format: :json), params: { query: "touhou" }

        assert_response :success
        assert_equal(4.hours.to_i, response.cache_control[:max_age].to_i)
      end

      should "not include the user's rate limit keys in publicly cached responses" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)

        get_auth related_tag_path(format: :json), create(:user), params: { query: "touhou" }

        assert_response :success
        assert_equal(true, response.cache_control[:public])
        assert_nil(response.headers["X-Rate-Limit"])
      end

      should "not cache .json responses for the current user's tags" do
        get related_tag_path(format: :json), params: { user_tags: true }

        assert_response :success
        assert_equal(0, response.cache_control[:max_age].to_i)
      end

      should "not cache .html responses" do
        get related_tag_path, params: { query: "touhou" }

        assert_response :success
        assert_equal(0, response.cache_control[:max_age].to_i)
      end

      should "be rate limited" do
        user = create(:user)
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "related_tags:show", key: user.cache_key, limited: true)

        get_auth related_tag_path(format: :json), user, params: { query: "touhou" }

        assert_response 429
      end
    end
  end
end
