require "test_helper"

class WikiPageVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The wiki page versions controller" do
    setup do
      @user = create(:user)
      @builder = create(:builder_user)
      as(@user) { @wiki_page = create(:wiki_page) }
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

      should "render when comparing against the current version" do
        get wiki_page_versions_path, params: { type: "current" }
        assert_response :success
      end

      should "not return more than 200 versions per page in HTML, or 1000 in the API" do
        WikiPageVersion.insert_all(Array.new(200) { { wiki_page_id: @wiki_page.id, updater_id: @user.id, title: @wiki_page.title, body: "foo", is_locked: false, created_at: Time.zone.now, updated_at: Time.zone.now } }) # rubocop:disable Rails/SkipsModelValidations

        get wiki_page_versions_path(limit: 1000), as: :json
        assert_response :success
        assert_equal(WikiPageVersion.count, response.parsed_body.size)

        get wiki_page_versions_path(limit: 1000)
        assert_response :success
        assert_select "tr[id^=wiki-page-version-]", count: 200
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

      should "show reordered other names as a change" do
        wiki_page = as(@user) { create(:wiki_page, other_names: ["aaa", "bbb"]) }
        as(@builder) { wiki_page.update!(other_names: ["bbb", "aaa"]) }
        version = wiki_page.versions.order(:id).last

        get wiki_page_versions_path, params: { search: { wiki_page_id: wiki_page.id }}
        assert_response :success
        assert_select "#wiki-page-version-#{version.id} .version-statuses", text: /OtherNames/
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

      should "only allow comparing against the previous or current version" do
        version = @wiki_page.versions.last

        assert_no_difference("WikiPageVersion.count") do
          get diff_wiki_page_versions_path, params: { thispage: version.id, type: "destroy" }
        end

        assert_response :success
      end
    end
  end
end
