require "test_helper"

class AutocompleteControllerTest < ActionDispatch::IntegrationTest
  def autocomplete(query, type)
    get autocomplete_index_path(search: { query: query, type: type }), as: :json
    assert_response :success

    response.parsed_body.map { |result| result["value"] }
  end

  def assert_autocomplete_equals(expected_value, query, type)
    assert_equal(expected_value, autocomplete(query, type))
  end

  context "Autocomplete controller" do
    context "index action" do
      setup do
        create(:tag, name: "azur_lane")
        create(:tag, name: "android")
        create(:tag, name: "original")
      end

      should "work for opensearch queries" do
        get autocomplete_index_path(search: { query: "azur", type: "opensearch" }), as: :json

        assert_response :success
        assert_equal(["azur", ["azur_lane"]], response.parsed_body)
      end

      should "work for tag queries" do
        assert_autocomplete_equals(["azur_lane"], "azur", "tag_query")
        assert_autocomplete_equals(["azur_lane"], "AZUR", "tag_query")

        assert_autocomplete_equals(["rating:sensitive"], "rating:s", "tag_query")
        assert_autocomplete_equals(["rating:sensitive"], "-rating:s", "tag_query")
      end

      should "work for a missing type" do
        get autocomplete_index_path(search: { query: "azur" }), as: :json

        assert_response :success
        assert_equal([], response.parsed_body)
      end

      should "work for the AND and OR keywords" do
        assert_autocomplete_equals(["android"], "and", "tag_query")
        assert_autocomplete_equals(["original"], "or", "tag_query")
      end

      should "not set session cookies when the response is publicly cached" do
        get autocomplete_index_path(search: { query: "azur", type: "tag_query" }), as: :json

        assert_response :success
        assert_equal(true, response.cache_control[:public])
        assert_equal({}, response.cookies)
      end
    end
  end
end
