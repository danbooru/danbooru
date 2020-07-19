require 'test_helper'

class WikiPageVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The wiki page versions controller" do
    setup do
      @user = create(:user, id: 100)
      @builder = create(:builder_user, name: "nitori")
      as(@user) { @wiki_page = create(:wiki_page, id: 101) }
      as(@builder) { @wiki_page.update(title: "supreme", body: "blah", other_names: ["not_this"]) }
      as(@user) { @wiki_page.update(body: "blah blah") }
    end

    context "index action" do
      setup do
        @versions = @wiki_page.versions
      end

      should "render" do
        get wiki_page_versions_path
        assert_response :success
      end

      should respond_to_search({}).with { @versions.reverse }
      should respond_to_search(title_matches: "supreme").with { [@versions[2], @versions[1]] }
      should respond_to_search(body_matches: "blah").with { [@versions[2], @versions[1]] }
      should respond_to_search(other_names_include_any: "not_this").with { [@versions[2], @versions[1]] }

      context "using includes" do
        should respond_to_search(wiki_page_id: 101).with { @versions.reverse }
        should respond_to_search(wiki_page_id: 102).with { [] }
        should respond_to_search(updater_id: 100).with { [@versions[2], @versions[0]] }
        should respond_to_search(updater_name: "nitori").with { @versions[1] }
        should respond_to_search(updater: {level: User::Levels::BUILDER}).with { @versions[1] }
      end
    end

    context "show action" do
      should "render" do
        get wiki_page_version_path(@wiki_page.versions.first)
        assert_response :success
      end
    end

    context "diff action" do
      should "render" do
        get diff_wiki_page_versions_path, params: { thispage: @wiki_page.versions.first.id, otherpage: @wiki_page.versions.last.id }
        assert_response :success
      end
    end
  end
end
