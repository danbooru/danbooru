require "test_helper"

class AutocompleteControllerTest < ActionDispatch::IntegrationTest
  context "Autocomplete controller" do
    context "index action" do
      setup do
        create(:tag, name: "azur_lane")
      end

      should "work for opensearch queries" do
        get autocomplete_index_path(query: "azur", variant: "opensearch"), as: :json
        assert_response :success
        assert_equal(["azur", ["azur lane"]], response.parsed_body)
      end
    end
  end
end
