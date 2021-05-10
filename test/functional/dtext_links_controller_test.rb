require "test_helper"

class DtextLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    as(@user) do
      @wiki = create(:wiki_page, title: "case", body: "[[test]]")
      @forum = create(:forum_post, topic: build(:forum_topic, title: "blah"), body: "[[case]]")
      create(:tag, name: "test")
    end
  end

  context "index action" do
    should "render" do
      get dtext_links_path
      assert_response :success
    end

    should respond_to_search({}).with { @forum.dtext_links + @wiki.dtext_links }

    context "using includes" do
      should respond_to_search(model_type: "WikiPage").with { @wiki.dtext_links }
      should respond_to_search(model_type: "ForumPost").with { @forum.dtext_links }
      should respond_to_search(has_linked_tag: "true").with { @wiki.dtext_links }
      should respond_to_search(has_linked_wiki: "true").with { @forum.dtext_links }
      should respond_to_search(ForumPost: {topic: {title_matches: "blah"}}).with { @forum.dtext_links }
      should respond_to_search(ForumPost: {topic: {title_matches: "nah"}}).with { [] }
    end
  end
end
