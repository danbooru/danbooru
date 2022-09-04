require "test_helper"

class AutocompleteControllerTest < ActionDispatch::IntegrationTest
  def autocomplete(query, type = "tag_query")
    get autocomplete_index_path(search: { query: query, type: type })
    assert_response :success

    response.parsed_body.css("li").map { |html| html["data-autocomplete-value"] }
  end

  def assert_autocomplete_equals(expected_value, query, type = "tag_query")
    assert_equal(expected_value, autocomplete(query, type))
  end

  context "Autocomplete controller" do
    context "index action" do
      should "work for opensearch queries" do
        create(:tag, name: "azur_lane")

        get autocomplete_index_path(search: { query: "azur", type: "opensearch" }), as: :json

        assert_response :success
        assert_equal(["azur", ["azur_lane"]], response.parsed_body)
      end

      should "work for simple tag queries" do
        create(:tag, name: "azur_lane")

        assert_autocomplete_equals(["azur_lane"], "azur")
        assert_autocomplete_equals(["azur_lane"], "AZUR")

        assert_autocomplete_equals(["rating:sensitive"], "rating:s")
        assert_autocomplete_equals(["rating:sensitive"], "-rating:s")
      end

      should "match tags containing the given words" do
        create(:tag, name: "short_hair", post_count: 15_000)
        create(:tag, name: "long_hair", post_count: 10_000)
        create(:tag, name: "very_long_hair", post_count: 5_000)
        create(:tag, name: "absurdly_long_hair", post_count: 1_000)
        create(:tag, name: "souryuu_asuka_langley")
        create(:tag, name: "crying_with_eyes_open")
        create(:tag, name: "open_mouth")
        create(:tag, name: "black_hair")
        create(:tag_alias, antecedent_name: "dark_hair", consequent_name: "black_hair")

        assert_autocomplete_equals(%w[long_hair very_long_hair absurdly_long_hair], "long_hair")
        assert_autocomplete_equals(%w[souryuu_asuka_langley], "asuka")
        assert_autocomplete_equals(%w[crying_with_eyes_open], "open_eyes")
        assert_autocomplete_equals(%w[open_mouth], "mouth_open")
        assert_autocomplete_equals(%w[black_hair], "dark")
      end

      should "work for an aliased tag" do
        create(:tag, name: "original")
        create(:tag_alias, antecedent_name: "oc", consequent_name: "original")

        assert_autocomplete_equals(["original"], "oc")
      end

      should "work for the user: metatag" do
        create(:user, name: "foobar")

        assert_autocomplete_equals(["user:foobar"], "user:foo")
      end

      should "work for the pool: metatag" do
        as(create(:user)) { create(:pool, name: "foobar") }

        assert_autocomplete_equals(["pool:foobar"], "pool:foo")
      end

      should "work for a missing type" do
        create(:tag, name: "azur_lane")

        get autocomplete_index_path(search: { query: "azur" }), as: :json

        assert_response :success
        assert_equal([], response.parsed_body)
      end

      should "work for the AND and OR keywords" do
        create(:tag, name: "android")
        create(:tag, name: "original")

        assert_autocomplete_equals(["android"], "and")
        assert_autocomplete_equals(["original"], "or")
      end

      should "not set session cookies when the response is publicly cached" do
        create(:tag, name: "azur_lane")

        get autocomplete_index_path(search: { query: "azur", type: "tag_query" })

        assert_response :success
        assert_equal(true, response.cache_control[:public])
        assert_equal({}, response.cookies)
      end
    end
  end
end
