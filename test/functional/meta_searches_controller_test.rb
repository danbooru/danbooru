require 'test_helper'

class MetaSearchesControllerTest < ActionDispatch::IntegrationTest
  context "The meta searches controller" do
    context "tags action" do
      should "work" do
        get meta_searches_tags_path, params: {name: "long_hair"}
        assert_response :success
      end
    end
  end
end
