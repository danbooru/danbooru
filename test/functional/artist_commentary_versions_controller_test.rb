require 'test_helper'

class ArtistCommentaryVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The artist commentary versions controller" do
    setup do
      @user = create(:member_user, id: 1000, created_at: 2.weeks.ago)
      @builder = create(:builder_user, created_at: 2.weeks.ago)
      as(@user) do
        @commentary = create(:artist_commentary, post: build(:post, id: 999, tag_string: "hakurei_reimu", uploader: @user))
      end
      as (@builder) { @commentary.update(original_title: "traslated") }
      as (@user) { @commentary.update(original_title: "translated") }
    end

    context "index action" do
      setup do
        @versions = @commentary.versions
        as(@builder) do
          @other_commentary = create(:artist_commentary, post: build(:post, uploader: @builder))
        end
        @other_versions = @other_commentary.versions
      end

      should "render" do
        get artist_commentary_versions_path
        assert_response :success
      end

      should respond_to_search({}).with { @other_versions + @versions.reverse }
      should respond_to_search(original_title: "translated").with { @versions[2] }
      should respond_to_search(text_matches: "traslated").with { @versions[1] }

      context "using includes" do
        should respond_to_search(post_id: 999).with { @versions.reverse }
        should respond_to_search(post_tags_match: "hakurei_reimu").with { @versions.reverse }
        should respond_to_search(post: {uploader: {level: User::Levels::BUILDER}}).with { @other_commentary.versions }
        should respond_to_search(updater_id: 1000).with { [@versions[2], @versions[0]] }
        should respond_to_search(updater: {level: User::Levels::BUILDER}).with { [@other_versions[0], @versions[1]] }
      end
    end

    context "show action" do
      should "work" do
        get artist_commentary_version_path(@commentary.versions.first)
        assert_redirected_to artist_commentary_versions_path(search: { post_id: @commentary.post_id })

        get artist_commentary_version_path(@commentary.versions.first), as: :json
        assert_response :success
      end
    end
  end
end
