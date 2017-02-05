require 'test_helper'

class NotePreviewsControllerTest < ActionController::TestCase
  context "The note previews controller" do
    context "show action" do
      should "work" do
        get :show, { body: "<b>test</b>", format: "json" }
        assert_response :success
      end
    end
  end
end
