require 'test_helper'

class DtextPreviewsControllerTest < ActionController::TestCase
  context "The dtext previews controller" do
    context "create action" do
      should "render" do
        post :create, { body: "h1. Touhou\n\n* [[touhou]]" }
        assert_response :success
      end
    end
  end
end
