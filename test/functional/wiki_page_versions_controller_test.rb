require "test_helper"

class WikiPageVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The wiki page versions controller" do
    setup do
      @user = create(:user)
      @builder = create(:builder_user)
      as(@user) { @wiki_page = create(:wiki_page, title: "old_name_x") }
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

      should "render previous title comparisons from old to new" do
        get wiki_page_versions_path, params: { search: { wiki_page_id: @wiki_page.id }, type: "previous" }

        assert_response :success
        assert_title_diff_direction
      end

      should "render current title comparisons from old to new" do
        get wiki_page_versions_path, params: { search: { wiki_page_id: @wiki_page.id }, type: "current" }

        assert_response :success
        assert_title_diff_direction
      end

      should respond_to_search.with { @versions.reverse }
      should respond_to_search(title_like: "supreme").with { [@versions[2], @versions[1]] }
      should respond_to_search(body_matches: "blah").with { [@versions[2], @versions[1]] }
      should respond_to_search(other_names_include_any: "not_this").with { [@versions[2], @versions[1]] }

      context "using includes" do
        should respond_to_search(wiki_page_id: -> { @wiki_page.id }).with { @versions.reverse }
        should respond_to_search(wiki_page_id: 0).with { [] }
        should respond_to_search(updater_id: -> { @user.id }).with { [@versions[2], @versions[0]] }
        should respond_to_search(updater_name: -> { @builder.name }).with { @versions[1] }
        should respond_to_search(updater: { level: User::Levels::BUILDER }).with { @versions[1] }
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

      should "work if only one version to diff is selected" do
        get diff_wiki_page_versions_path, params: { thispage: @wiki_page.versions.first.id }
        assert_response :success
      end

      should "fail if no version is selected" do
        get diff_wiki_page_versions_path
        assert_redirected_to wiki_pages_path
      end
    end
  end

  private

  def assert_title_diff_direction
    assert_select "td.diff-body" do |cells|
      assert(cells.any? do |cell|
        cell.at_css("del")&.text == "old_name_x" && cell.at_css("ins")&.text == "supreme"
      end)
    end
  end
end
