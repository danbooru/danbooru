require 'test_helper'

class ArtistVersionsControllerTest < ActionDispatch::IntegrationTest
  context "An artist versions controller" do
    setup do
      @user = create(:gold_user, id: 100)
      @builder = create(:builder_user, name: "danbo")
      as(@builder) { @artist = create(:artist, name: "masao", url_string: "https://masao.deviantart.com") }
      as(@user) { @artist.update(name: "masao_(deleted)", is_deleted: true) }
      as(@builder) { @artist.update(name: "masao", is_deleted: false, group_name: "the_best", url_string: "https://www.deviantart.com/masao") }
    end

    context "index action" do
      setup do
        @versions = @artist.versions
      end

      should "render" do
        get artist_versions_path
        assert_response :success
      end

      should respond_to_search({}).with { @versions.reverse }
      should respond_to_search(name: "masao").with { [@versions[2], @versions[0]] }
      should respond_to_search(name_matches: "(deleted)").with { @versions[1] }
      should respond_to_search(group_name_matches: "the_best").with { @versions[2] }
      should respond_to_search(urls_include_any: "https://www.deviantart.com/masao").with { @versions[2] }
      should respond_to_search(is_deleted: "true").with { @versions[1] }

      context "using includes" do
        should respond_to_search(updater_id: 100).with { @versions[1] }
        should respond_to_search(updater_name: "danbo").with { [@versions[2], @versions[0]] }
        should respond_to_search(updater: {level: User::Levels::BUILDER}).with { [@versions[2], @versions[0]] }
        should respond_to_search(artist: {name: "masao"}).with { @versions.reverse }
        should respond_to_search(artist: {name: "doesntexist"}).with { [] }
      end
    end

    context "show action" do
      should "work" do
        get artist_version_path(@artist.versions.first)
        assert_redirected_to artist_versions_path(search: { artist_id: @artist.id })

        get artist_version_path(@artist.versions.first), as: :json
        assert_response :success
      end
    end
  end
end
