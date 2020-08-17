require 'test_helper'

class ArtistCommentariesControllerTest < ActionDispatch::IntegrationTest
  context "The artist commentaries controller" do
    setup do
      @user = create(:user, id: 1000, name: "danbo", created_at: 2.weeks.ago)
      as(@user) do
        @commentary = create(:artist_commentary, post: build(:post, id: 999, tag_string: "hakurei_reimu", uploader: @user), original_title: "ot1", translated_title: "tt1")
        @other_commentary = create(:artist_commentary, translated_title: "", translated_description: "")
      end
    end

    context "index action" do
      setup do
        @deleted_commentary = create(:artist_commentary, original_title: "", original_description: "", translated_title: "", translated_description: "")
      end

      should "render" do
        get artist_commentaries_path
        assert_response :success
      end

      should respond_to_search({}).with { [@deleted_commentary, @other_commentary, @commentary] }
      should respond_to_search(text_matches: "ot1").with { @commentary }
      should respond_to_search(original_present: "true").with { [@other_commentary, @commentary] }
      should respond_to_search(translated_present: "true").with { @commentary }
      should respond_to_search(is_deleted: "yes").with { @deleted_commentary }

      context "using includes" do
        should respond_to_search(post_id: 999).with { @commentary }
        should respond_to_search(post_tags_match: "hakurei_reimu").with { @commentary }
        should respond_to_search(post: {uploader_name: "danbo"}).with { @commentary }
      end
    end

    context "show action" do
      should "render" do
        get artist_commentary_path(@commentary.id)
        assert_redirected_to(@commentary.post)

        get artist_commentary_path(post_id: @commentary.post_id)
        assert_redirected_to(@commentary.post)
      end
    end

    context "create_or_update action" do
      should "render for create" do
        params = {
          artist_commentary: {
            original_title: "foo",
            post_id: FactoryBot.create(:post).id
          },
          format: "js"
        }

        assert_difference("ArtistCommentary.count", 1) do
          put_auth create_or_update_artist_commentaries_path(params), @user, as: :js
        end
        assert_response :success
      end

      should "render for update" do
        params = {
          artist_commentary: {
            post_id: @commentary.post_id,
            original_title: "foo"
          },
          format: "js"
        }

        put_auth create_or_update_artist_commentaries_path(params), @user
        @commentary.reload
        assert_response :success
        assert_equal("foo", @commentary.reload.original_title)
      end
    end

    context "revert action" do
      should "work" do
        original_title = @commentary.original_title
        @commentary.update(original_title: "foo")
        @commentary.reload
        put_auth revert_artist_commentary_path(@commentary.post_id, version_id: @commentary.versions.first.id, format: "js"), @user
        assert_response :success
        assert_equal(original_title, @commentary.reload.original_title)
      end

      should "return 404 when trying to revert a nonexistent commentary" do
        put_auth revert_artist_commentary_path(-1, version_id: -1, format: "js"), @user
        assert_response 404
      end

      should "not allow reverting to a previous version of another artist commentary" do
        put_auth revert_artist_commentary_path(@commentary.post_id, version_id: @other_commentary.versions.first.id, format: "js"), @user
        @commentary.reload
        assert_not_equal(@commentary.original_title, @other_commentary.original_title)
        assert_response :missing
      end
    end
  end
end
