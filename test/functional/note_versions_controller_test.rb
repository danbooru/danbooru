require 'test_helper'

class NoteVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The note versions controller" do
    setup do
      @user = create(:user)
      @user_2 = create(:user)

      as(@user) { @note = create(:note) }
      as(@user_2) { @note.update(body: "1 2") }
      as(@user) { @note.update(body: "1 2 3") }
    end

    context "index action" do
      should "list all versions" do
        get note_versions_path
        assert_response :success
      end

      should "list all versions that match the search criteria" do
        get note_versions_path, params: {:search => {:updater_id => @user_2.id}}
        assert_response :success
      end
    end

    context "show action" do
      should "work" do
        get note_version_path(@note.versions.first)
        assert_redirected_to note_versions_path(search: { note_id: @note.id })

        get note_version_path(@note.versions.first), as: :json
        assert_response :success
      end
    end
  end
end
