require 'test_helper'

class DtextPreviewsControllerTest < ActionDispatch::IntegrationTest
  context "The dtext previews controller" do
    context "create action" do
      should "render" do
        post dtext_preview_path, params: { body: "h1. Touhou\n\n* [[touhou]]" }
        assert_response :success
      end
    end
  end
end
