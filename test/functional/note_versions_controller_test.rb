require 'test_helper'

class NoteVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The note versions controller" do
    setup do
      @user = create(:user, id: 100)
      @user_2 = create(:user, name: "cirno")

      as(@user) { @note = create(:note, id: 101) }
      as(@user_2) { @note.update(body: "blah", is_active: false) }
      as(@user) { @note.update(body: "1 2 3", is_active: true) }
    end

    context "index action" do
      setup do
        @versions = @note.versions
      end

      should "render" do
        get note_versions_path
        assert_response :success
      end

      should respond_to_search({}).with { @versions.reverse }
      should respond_to_search(body_matches: "blah").with { @versions[1] }
      should respond_to_search(version: 1).with { @versions[0] }
      should respond_to_search(is_active: "false").with { @versions[1] }

      context "using includes" do
        should respond_to_search(note_id: 101).with { @versions.reverse }
        should respond_to_search(note_id: 102).with { [] }
        should respond_to_search(updater_id: 100).with { [@versions[2], @versions[0]] }
        should respond_to_search(updater: {name: "cirno"}).with { @versions[1] }
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
