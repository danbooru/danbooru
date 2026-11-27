require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest
  context "The notes controller" do
    setup do
      @user = create(:user)
      @note = as(@user) { create(:note, body: "000") }
    end

    should "return 404 for actions that don't exist" do
      get_auth "/notes/new", @user
      assert_response 404

      get_auth "/notes/#{@note.id}/edit", @user
      assert_response 404
    end

    context "index action" do
      setup do
        as(@user) do
          @post_note = create(:note, post: build(:post, tag_string: "touhou"))
          @deleted_note = create(:note, is_active: false)
        end
      end

      should "render" do
        get notes_path
        assert_response :success
      end

      should "not return more than 200 notes per page in HTML, or 1000 in the API" do
        Note.insert_all!(Array.new(200) { @note.attributes.except("id") }) # rubocop:disable Rails/SkipsModelValidations

        get notes_path(limit: 1000), as: :json
        assert_response :success
        assert_operator(response.parsed_body.size, :>, 200)

        get notes_path(limit: 1000)
        assert_response :success
        assert_select "tbody tr", count: 200
      end

      should respond_to_search.with { [@deleted_note, @post_note, @note] }
      should respond_to_search(body_matches: "000").with { @note }
      should respond_to_search(is_active: "true").with { [@post_note, @note] }

      should respond_to_search(post_id: -> { @post_note.post_id }).with { @post_note }
      should respond_to_search(post_tags_match: "touhou").with { @post_note }
    end

    context "show action" do
      should "render" do
        get note_path(@note), params: { format: "json" }
        assert_response :success
      end
    end

    context "create action" do
      should "return an error for a missing body" do
        assert_no_difference("Note.count") do
          post_auth notes_path, @user, params: { note: { x: 0, y: 0, width: 10, height: 10, post_id: create(:post).id }}, as: :json
        end

        assert_response 422
      end

      should "create a note" do
        assert_difference("Note.count", 1) do
          post = create(:post)
          post_auth notes_path, @user, params: { note: { x: 0, y: 0, width: 10, height: 10, body: "abc", post_id: post.id }, format: :json }

          assert_response :success
          assert_equal(1, post.notes.count)
        end
      end

      should "not create a note on a banned post" do
        post = create(:post, is_banned: true)
        post_auth notes_path, @user, params: { note: { x: 0, y: 0, width: 10, height: 10, body: "abc", post_id: post.id }, format: :json }

        assert_response 403
        assert_equal(0, post.notes.count)
      end

      should "not create a note on a post that cannot have notes" do
        post = create(:post, file_ext: "webm")
        post_auth notes_path, @user, params: { note: { x: 0, y: 0, width: 10, height: 10, body: "abc", post_id: post.id }, format: :json }

        assert_response 422
        assert_equal(0, post.notes.count)
      end
    end

    context "update action" do
      should "update a note" do
        put_auth note_path(@note), @user, params: { note: { body: "xyz" }}
        assert_redirected_to @note
        assert_equal("xyz", @note.reload.body)
      end

      should "not update a note on a banned post" do
        @note.post.update!(is_banned: true)
        put_auth note_path(@note), @user, params: { note: { body: "xyz" }, format: :json }

        assert_response 403
        assert_equal("000", @note.reload.body)
      end

      should "not allow changing the post id to another post" do
        @other = create(:post)
        put_auth note_path(@note), @user, params: { format: "json", id: @note.id, note: { post_id: @other.id }}
        assert_response 403
        assert_not_equal(@other.id, @note.reload.post_id)
      end
    end

    context "destroy action" do
      should "destroy a note" do
        delete_auth note_path(@note), @user
        assert_redirected_to @note
        assert_equal(false, @note.reload.is_active?)
      end
    end

    context "revert action" do
      setup do
        as(@user) do
          travel(1.day) do
            @note.update(body: "111")
          end
          travel(2.days) do
            @note.update(body: "222")
          end
        end
      end

      should "revert to a previous version" do
        put_auth revert_note_path(@note), @user, params: { version_id: @note.versions.first.id }
        assert_redirected_to @note
        assert_equal("000", @note.reload.body)
      end

      should "not allow reverting to a previous version of another note" do
        as(@user) do
          @note2 = create(:note, body: "note 2")
        end
        put_auth revert_note_path(@note), @user, params: { version_id: @note2.versions.first.id }
        assert_not_equal(@note.reload.body, @note2.body)
        assert_response :missing
      end
    end

    context "preview action" do
      should "not work for a logged out user" do
        note = { x: 0, y: 0, width: 10, height: 10, body: "test", post_id: @note.post_id }
        post preview_notes_path, params: { note: note, format: "json" }

        assert_response 403
      end

      should "work for a POST method" do
        note = { x: 0, y: 0, width: 10, height: 10, body: '<p>test</p> <script>alert("owned")</script>', post_id: @note.post_id }
        post_auth preview_notes_path, @user, params: { note: note, format: "json" }

        assert_response :success
        assert_equal("<p>test</p> ", response.parsed_body["sanitized_body"])
      end

      should "work for a GET method" do
        note = { x: 0, y: 0, width: 10, height: 10, body: '<p>test</p> <script>alert("owned")</script>', post_id: @note.post_id }
        get_auth preview_notes_path, @user, params: { note: note, format: "json" }

        assert_response :success
        assert_equal("<p>test</p> ", response.parsed_body["sanitized_body"])
      end

      should "reject oversized bodies before sanitizing" do
        note = { x: 0, y: 0, width: 10, height: 10, body: "x" * 10_000, post_id: @note.post_id }
        post_auth preview_notes_path, @user, params: { note: note, format: "json" }

        assert_response 422
      end

      should "be rate limited" do
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "notes:preview", key: @user.cache_key, limited: true)

        note = { x: 0, y: 0, width: 10, height: 10, body: "test", post_id: @note.post_id }
        post_auth preview_notes_path, @user, params: { note: note, format: "json" }

        assert_response 429
      end
    end
  end
end
