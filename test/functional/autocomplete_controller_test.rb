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

  def assert_autocomplete_highlights(expected_results, query, type = "tag_query")
    get autocomplete_index_path(search: { query: query, type: type })
    assert_response :success

    results = response.parsed_body.css("li a").map do |html|
      html.inner_html.strip.remove(/<\/?span>/).gsub(/<b>(.*?)<\/b>/) { $1.upcase }
    end

    assert_equal(results, expected_results)
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
        create(:user, name: "foobar")
        as(create(:user)) { create(:pool, name: "foobar") }
        create(:tag, name: "short_hair", post_count: 15_000)
        create(:tag, name: "long_hair", post_count: 10_000)
        create(:tag, name: "very_long_hair", post_count: 5_000)
        create(:tag, name: "absurdly_long_hair", post_count: 1_000)
        create(:tag, name: "souryuu_asuka_langley")
        create(:tag, name: "crying_with_eyes_open")
        create(:tag, name: "open_mouth")
        create(:tag, name: "black_hair")
        create(:tag, name: "original")
        create(:tag_alias, antecedent_name: "dark_hair", consequent_name: "black_hair")
        create(:tag_alias, antecedent_name: "oc", consequent_name: "original")

        assert_autocomplete_equals(%w[long_hair very_long_hair absurdly_long_hair], "long_hair")
        assert_autocomplete_equals(%w[souryuu_asuka_langley], "asuka")
        assert_autocomplete_equals(%w[crying_with_eyes_open], "open_eyes")
        assert_autocomplete_equals(%w[open_mouth], "mouth_open")
        assert_autocomplete_equals(%w[black_hair], "dark")
        assert_autocomplete_equals(%w[original], "oc")

        assert_autocomplete_equals(["user:foobar"], "user:foo")
        assert_autocomplete_equals(["pool:foobar"], "pool:foo")
      end

      should "highlight matches correctly" do
        create(:tag, name: "short_hair")
        create(:tag, name: "very_long_hair")
        create(:tag, name: "short_shorts")
        create(:tag, name: "sleeves_rolled_up")
        create(:tag, name: "jack-o'-lantern")
        create(:tag, name: %q{don't_say_"lazy"})

        assert_autocomplete_highlights([%q{don't say "LAZY"}], "lazy")

        assert_autocomplete_highlights(["VERY long hair"], "very")
        assert_autocomplete_highlights(["very LONG hair"], "long")
        assert_autocomplete_highlights(["short HAIR", "very long HAIR"], "hair")

        assert_autocomplete_highlights(["SLEEVES ROLLED UP"], "sleeves_rolled_up")
        assert_autocomplete_highlights(["SLEEVES ROLLED UP"], "rolled-up_sleeves")

        assert_autocomplete_highlights(["JACK-O'-LANTERN"], "jack-o'-lantern")
        assert_autocomplete_highlights(["JACK-O'-LANTERN"], "jack_o'_lantern")
        assert_autocomplete_highlights(["JACK-O'-LANTERN"], "jack_o_lantern")

        assert_autocomplete_highlights(["SHORT hair", "SHORT SHORTs"], "short")
        assert_autocomplete_highlights(["SHORT SHOrts", "SHORT hair"], "short_sho")

        assert_autocomplete_highlights(["VERY long hair"], "very*")
        assert_autocomplete_highlights(["very LONG hair"], "*long*")
        assert_autocomplete_highlights(["short HAIR", "very long HAIR"], "*hair")
        assert_autocomplete_highlights(["VEry LOng HAir"], "*ve*lo*ha*")
        assert_autocomplete_highlights(["vERy lONg hAIr"], "*er*on*ai*")
        assert_autocomplete_highlights(["veRY loNG haIR"], "*ry*ng*ir*")
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
