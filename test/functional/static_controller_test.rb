require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  context "site_map action" do
    should "work for anonymous users" do
      get site_map_path
      assert_response :success
    end

    should "work for admin users" do
      get_auth site_map_path, create(:admin_user)
      assert_response :success
    end
  end

  context "sitemap action" do
    [Artist, ForumTopic, Pool, Post, Tag, User, WikiPage].each do |klass|
      should "work for #{klass.model_name.plural}" do
        as(create(:user)) { create_list(klass.model_name.singular.to_sym, 3) }
        get sitemap_path(sitemap: klass.model_name.plural), as: :xml

        assert_response :success
        assert_equal(1, response.parsed_body.css("sitemap loc").size)
      end
    end

    should "work when the sitemap is empty" do
      get sitemap_path(sitemap: "pools"), as: :xml

      assert_response :success
    end
  end

  context "dtext_help action" do
    should "work" do
      get dtext_help_path(format: :js), xhr: true
      assert_response :success
    end
  end

  context "terms_of_service action" do
    should "work" do
      get terms_of_service_path
      assert_response :success
    end
  end

  context "privacy_policy action" do
    should "work" do
      get privacy_policy_path
      assert_response :success
    end
  end

  context "2257 action" do
    should "work" do
      get usc_2257_path
      assert_response :success
    end
  end

  context "not_found action" do
    should "return the 404 page for GET requests" do
      get "/qwoiqogieqg"
      assert_response 404
    end

    should "return the 404 page for POST requests" do
      post "/qwoiqogieqg"
      assert_response 404
    end

    should "return a JSON response for a 404'd JSON request" do
      get "/qwoiqogieqg", as: :json

      assert_response 404
      assert_equal("Page not found", response.parsed_body["message"])
    end

    should "return an XML response for a 404'd XML request" do
      get "/qwoiqogieqg", as: :xml

      assert_response 404
      assert_equal("Page not found", response.parsed_body.xpath("result/message").text)
    end

    should "return a JS response for a 404'd .js request" do
      get "/qwoiqogieqg.js"

      assert_response 404
      assert_equal("", response.body)
    end

    should "render the 404 page when page_not_found_pool_id is configured" do
      as(create(:user)) do
        @post = create(:post, tag_string: "artist:bkub")
        @pool = create(:pool, post_ids: [@post.id])
        Danbooru.config.stubs(:page_not_found_pool_id).returns(@pool.id)
      end

      get "/qwoiqogieqg"

      assert_response 404
      assert_select "#c-static #a-not-found img", count: 1
    end
  end

  context "bookmarklet action" do
    should "work" do
      get bookmarklet_path
      assert_response :success
    end
  end

  context "contact action" do
    should "work" do
      create(:owner_user)

      get contact_path
      assert_response :success
    end
  end

  context "keyboard_shortcuts action" do
    should "work" do
      get keyboard_shortcuts_path
      assert_response :success
    end
  end

  context "opensearch action" do
    should "work" do
      get opensearch_path, as: :xml
      assert_response :success
    end
  end
end
