require "test_helper"

class NoteVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The note versions controller" do
    setup do
      @user = create(:user)
      @user2 = create(:user)

      as(@user) { @note = create(:note) }
      as(@user2) { @note.update(body: "blah", is_active: false) }
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

      should "render previous comparisons from old to new" do
        get note_versions_path, params: { search: { note_id: @note.id }, type: "previous" }

        assert_response :success
        assert_body_diff_direction
      end

      should "render current comparisons from old to new" do
        get note_versions_path, params: { search: { note_id: @note.id }, type: "current" }

        assert_response :success
        assert_body_diff_direction
      end

      should respond_to_search.with { @versions.reverse }
      should respond_to_search(body_matches: "blah").with { @versions[1] }
      should respond_to_search(version: 1).with { @versions[0] }
      should respond_to_search(is_active: "false").with { @versions[1] }

      should respond_to_search(note_id: -> { @note.id }).with { @versions.reverse }
      should respond_to_search(note_id: 0).with { [] }
      should respond_to_search(updater_id: -> { @user.id }).with { [@versions[2], @versions[0]] }
      should respond_to_search(updater: { name: -> { @user2.name }}).with { @versions[1] }
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

  private

  def assert_body_diff_direction
    assert_select "td.diff-body" do |cells|
      assert(cells.any? do |cell|
        cell.at_css("del")&.text == "blah" && cell.at_css("ins")&.text == "1 2 3"
      end)
    end
  end
end
