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

      should "render when comparing against the current version" do
        get note_versions_path, params: { type: "current" }
        assert_response :success
      end

      should "only allow comparing against the previous or current version" do
        assert_no_difference("NoteVersion.count") do
          get note_versions_path, params: { type: "destroy" }
        end

        assert_response :success
      end

      should "not return more than 200 versions per page in HTML, or 1000 in the API" do
        NoteVersion.insert_all(Array.new(200) { { note_id: @note.id, post_id: @note.post_id, updater_id: @user.id, x: 0, y: 0, width: 1, height: 1, body: "foo", created_at: Time.zone.now, updated_at: Time.zone.now } }) # rubocop:disable Rails/SkipsModelValidations

        get note_versions_path(limit: 1000), as: :json
        assert_response :success
        assert_equal(NoteVersion.count, response.parsed_body.size)

        get note_versions_path(limit: 1000)
        assert_response :success
        assert_select "tr[id^=note-version-]", count: 200
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
end
