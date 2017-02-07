require 'test_helper'

class MetaSearchesControllerTest < ActionController::TestCase
  context "The meta searches controller" do
    context "tags action" do
      should "work" do
        get :tags, { name: "long_hair" }
        assert_response :success
      end
    end
  end
end
