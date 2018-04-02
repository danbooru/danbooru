require 'test_helper'

class NotePreviewsControllerTest < ActionDispatch::IntegrationTest
  context "The note previews controller" do
    context "show action" do
      should "work" do
        get note_previews_path, params: { body: "<b>test</b>", format: "json" }
        assert_response :success
      end
    end
  end
end
