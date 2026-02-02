require "test_helper"

class DtextLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @mod = create(:mod_user)
    @secret_forum = create(:forum_post, topic: build(:forum_topic, title: "mod thread", min_level: 40), body: "[[hidden link]]")
    as(@user) do
      @wiki = create(:wiki_page, title: "case", body: "[[test]]")
      @forum = create(:forum_post, topic: build(:forum_topic, title: "blah"), body: "[[case]]")
      @pool = create(:pool, description: "[[case]]")
      create(:tag, name: "test")
    end
  end

  context "index action" do
    should "render" do
      get dtext_links_path
      assert_response :success
    end

    should respond_to_search({}).with { @pool.dtext_links + @forum.dtext_links + @wiki.dtext_links }
    should respond_to_search(ForumPost: { topic: { min_level: 40 } }).with { [] }

    context "using includes" do
      should respond_to_search(model_type: "WikiPage").with { @wiki.dtext_links }
      should respond_to_search(model_type: "ForumPost").with { @forum.dtext_links }
      should respond_to_search(model_type: "Pool").with { @pool.dtext_links }
      should respond_to_search(has_linked_tag: "true").with { @wiki.dtext_links }
      should respond_to_search(has_linked_wiki: "true").with { @pool.dtext_links + @forum.dtext_links }
      should respond_to_search(ForumPost: {topic: {title_matches: "blah"}}).with { @forum.dtext_links }
      should respond_to_search(ForumPost: {topic: {title_matches: "nah"}}).with { [] }
    end
  end

  context "as a mod" do
    setup do
      CurrentUser.user = create(:mod_user)
    end

    should respond_to_search(ForumPost: { topic: { min_level: 40 } }).with { @secret_forum.dtext_links }
  end
end
