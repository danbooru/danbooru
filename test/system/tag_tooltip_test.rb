require "application_system_test_case"

class TagTooltipChromeTest < ChromeSystemTestCase
  context "Tag tooltips" do
    setup do
      @tag = create(:tag, name: "touhou", category: Tag.categories.copyright, post_count: 1)
      create(:wiki_page, title: @tag.name, body: "Touhou is a series of games.")
      @post = create(:post, tag_string: @tag.name)
    end

    context "on a post's tag list" do
      should "show the tooltip when hovering over the tag" do
        visit post_path(@post)

        find(".search-tag", text: "touhou").hover
        assert_selector ".tag-tooltip"
      end
    end

    context "for a wikiless artist tag" do
      should "not prompt to create a wiki page" do
        create(:tag, name: "some_artist", category: Tag.categories.artist, post_count: 1)
        post = create(:post, tag_string: "some_artist")

        visit post_path(post)

        find(".search-tag", text: "some artist").hover
        assert_selector ".tag-tooltip-text", text: "Artist."
      end
    end

    context "for a tag with a video embed" do
      should "show a static thumbnail" do
        video_post = create(:post_with_file, filename: "webm/test-512x512.webm", tag_string: "videotag")
        create(:wiki_page, title: "videotag", body: "!post ##{video_post.id}")
        post = create(:post, tag_string: "videotag")

        visit post_path(post)

        find(".search-tag", text: "videotag").hover
        assert_selector ".tag-tooltip"

        assert_selector ".tag-tooltip .tag-tooltip-embed img"
        assert_no_selector ".tag-tooltip .video-component"
      end
    end

    context "on a [[tag]] dtext link" do
      should "show the tooltip" do
        user = create(:user, created_at: 1.month.ago)
        comment = as(user) { create(:comment, post: @post, body: "[[touhou]]") }

        visit comment_path(comment)
        find(".dtext-wiki-link", text: "touhou").hover
        assert_selector ".tag-tooltip"
      end
    end

    context "hovering over multiple tags in a row" do
      should "hide the previous tooltip instead of showing both at once" do
        create(:tag, name: "1girl", post_count: 1)
        post = create(:post, tag_string: "touhou 1girl")

        visit post_path(post)

        find(".search-tag", text: "touhou").hover
        assert_selector ".tag-tooltip"

        find(".search-tag", text: "1girl").hover
        assert_selector ".tag-tooltip", count: 1
      end
    end

    context "on a tag inside a post tooltip's tag list" do
      should "not hide the post tooltip" do
        create(:post, tag_string: @tag.name)

        visit posts_path

        first(".post-preview img").hover
        assert_selector ".post-tooltip-body"

        find(".post-tooltip-body .search-tag", text: "touhou").hover
        assert_selector ".tag-tooltip"
        assert_selector ".post-tooltip-body"
      end

      should "not inherit the parent's tooltip size" do
        long_tag = create(:tag, name: "long_wiki_tag", post_count: 1)
        create(:wiki_page, title: long_tag.name, body: "word " * 200)
        create(:post, tag_string: "#{@tag.name} #{long_tag.name}")

        visit posts_path

        first(".post-preview img").hover
        assert_selector ".post-tooltip-body"

        find(".post-tooltip-body .search-tag", text: "long_wiki_tag").hover
        assert_selector ".tag-tooltip"

        # The tag tooltip must escape the post tooltip's scrollable body, or it would get clipped/squashed to fit inside it.
        assert_no_selector ".post-tooltip-body .tag-tooltip"
      end
    end
  end
end
