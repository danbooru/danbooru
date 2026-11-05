require "test_helper"

class CountsControllerTest < ActionDispatch::IntegrationTest
  context "The counts commentary controller" do
    context "posts action" do
      should "render" do
        get posts_counts_path
        assert_response :success
      end

      should "render for json" do
        get posts_counts_path(format: :json)
        assert_response :success
      end

      should "render for xml" do
        get posts_counts_path(format: :xml)
        assert_response :success
      end

      should "return a 422 error for searches with too many tags" do
        get posts_counts_path(format: :json, tags: "a b c")
        assert_response 422

        get_auth posts_counts_path(format: :json, tags: "a b c"), create(:user)
        assert_response 422
      end

      should "allow searches with more tags for users with a higher tag limit" do
        get_auth posts_counts_path(format: :json, tags: "a b c"), create(:platinum_user)
        assert_response :success
      end

      should "ignore estimate_count and skip_cache for non-builders" do
        PostQuery.any_instance.expects(:fast_count).with(has_entries(estimate_count: true, skip_cache: false)).twice.returns(0)

        get posts_counts_path(format: :json, tags: "touhou", estimate_count: "false", skip_cache: "true")
        assert_response :success

        get_auth posts_counts_path(format: :json, tags: "touhou", estimate_count: "false", skip_cache: "true"), create(:gold_user)
        assert_response :success
      end

      should "respect estimate_count and skip_cache for builders" do
        PostQuery.any_instance.expects(:fast_count).with(has_entries(estimate_count: false, skip_cache: true)).returns(0)

        get_auth posts_counts_path(format: :json, tags: "touhou", estimate_count: "false", skip_cache: "true"), create(:builder)
        assert_response :success
      end

      should "be rate limited" do
        user = create(:user)
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "counts:posts", key: user.cache_key, limited: true)

        get_auth posts_counts_path(format: :json, tags: "touhou"), user

        assert_response 429
      end
    end
  end
end
