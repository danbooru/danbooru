require "test_helper"

class RenameCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the rename command" do
    context "on creation" do
      should "fail if the old tag doesn't exist" do
        @bur = build(:bulk_update_request, script: "rename aaa -> bbb")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't rename [[aaa]] -> [[bbb]] ([[aaa]] doesn't exist)"], @bur.errors.full_messages)
      end

      should "fail if the old tag has more than 200 posts" do
        create(:tag, name: "aaa", post_count: 1000)
        @bur = build(:bulk_update_request, script: "rename aaa -> bbb")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't rename [[aaa]] -> [[bbb]] ([[aaa]] has more than 200 posts, use an alias instead)"], @bur.errors.full_messages)
      end

      should "fail if the consequent name is invalid" do
        create(:tag, name: "tag")
        @bur = build(:bulk_update_request, script: "rename tag -> tag_")

        assert_equal(false, @bur.valid?)
        assert_equal(["Can't rename [[tag]] -> [[tag_]] ('tag_' cannot end with an underscore)"], @bur.errors.full_messages)
      end
    end

    context "on approval" do
      should "rename the tags" do
        create(:artist, name: "foo")
        create(:wiki_page, title: "foo", body: "[[foo]]")
        @post = create(:post, tag_string: "foo blah")
        @bur = create_bur!("rename foo -> bar", @admin)

        assert_equal("bar blah", @post.reload.tag_string)
        assert_equal("approved", @bur.reload.status)
        assert_equal(User.system, @post.versions.last.updater)
      end

      should "move the tag's artist entry and wiki page" do
        @artist = create(:artist, name: "foo")
        @wiki = create(:wiki_page, title: "foo", body: "[[foo]]")
        create(:post, tag_string: "foo blah")
        create_bur!("rename foo -> bar", @admin)

        assert_equal("bar", @artist.reload.name)
        assert_equal("bar", @wiki.reload.title)
        assert_equal("[[bar]]", @wiki.body)
      end

      context "when moving an artist" do
        should "add the artist's old tag name to their other names" do
          @artist = create(:artist, name: "foo")
          create(:wiki_page, title: "foo", body: "[[foo]]")
          create(:post, tag_string: "foo blah")
          create_bur!("rename foo -> bar", @admin)

          assert_equal(["foo"], @artist.reload.other_names)
        end
      end

      context "when renaming a character tag with a *_(cosplay) tag" do
        should "move the *_(cosplay) tag as well" do
          @post = create(:post, tag_string: "toosaka_rin_(cosplay)")
          @wiki = create(:wiki_page, title: "toosaka_rin_(cosplay)")

          create_bur!("rename toosaka_rin -> tohsaka_rin", @admin)

          assert_equal("cosplay tohsaka_rin tohsaka_rin_(cosplay)", @post.reload.tag_string)
          assert_equal("tohsaka_rin_(cosplay)", @wiki.reload.title)
        end
      end

      context "when renaming an artist tag with a *_(style) tag" do
        should "move the *_(style) tag as well" do
          create(:tag, name: "tanaka_takayuki", category: Tag.categories.artist)
          @post = create(:post, tag_string: "tanaka_takayuki_(style)")
          @wiki = create(:wiki_page, title: "tanaka_takayuki_(style)")

          create_bur!("rename tanaka_takayuki -> tony_taka", @admin)

          assert_equal("tony_taka_(style)", @post.reload.tag_string)
          assert_equal("tony_taka_(style)", @wiki.reload.title)
        end
      end

      context "when rewriting wiki pages" do
        should "rewrite wiki pages to use the new tag" do
          create(:tag, name: "aaa")
          @wiki = create(:wiki_page, body: "[[aaa]] bar")

          create_bur!("rename aaa -> bbb", @admin)

          assert_equal("[[bbb]] bar", @wiki.reload.body)
        end

        should "not fail to rewrite wiki pages if the body is too long" do
          create(:tag, name: "aaa")
          @wiki = build(:wiki_page, title: "foo", body: "[[aaa]] bar #{"x" * WikiPage::MAX_WIKI_LENGTH}")
          @wiki.save!(validate: false)

          create_bur!("rename aaa -> bbb", @admin)

          assert_equal("[[bbb]] bar #{"x" * WikiPage::MAX_WIKI_LENGTH}", @wiki.reload.body)
        end
      end

      context "when rewriting pool descriptions" do
        should "rewrite pool descriptions to use the new tag" do
          create(:tag, name: "aaa")
          @pool = create(:pool, description: "foo [[aaa]] bar")

          create_bur!("rename aaa -> bbb", @admin)

          assert_equal("foo [[bbb]] bar", @pool.reload.description)
        end

        should "not fail to rewrite pool descriptions if the pool description is too long" do
          create(:tag, name: "aaa")
          @pool = build(:pool, description: "foo [[aaa]] bar #{"x" * Pool::MAX_DESCRIPTION_LENGTH}")
          @pool.save!(validate: false)

          create_bur!("rename aaa -> bbb", @admin)

          assert_equal("foo [[bbb]] bar #{"x" * Pool::MAX_DESCRIPTION_LENGTH}", @pool.reload.description)
        end
      end

      context "when moving blacklisted tags" do
        should "move blacklisted tags" do
          create(:tag, name: "old_tag")
          user = create(:user, blacklisted_tags: "old_tag")
          create_bur!("rename old_tag -> new_tag", @admin)

          assert_equal(true, user.reload.blacklisted_tags.split.include?("new_tag"))
        end

        should "not fail if the user has too many blacklisted tags" do
          user = build(:user, blacklisted_tags: User::MAX_BLACKLIST_TAGS.succ.times.map { |n| create(:tag, name: "tag#{n}").name }.join("\n"))
          user.save!(validate: false)

          create_bur!("rename tag0 -> new_tag", @admin)

          assert_equal(true, user.reload.blacklisted_tags.split.include?("new_tag"))
        end
      end

      context "when moving saved searches" do
        should "move saved searches" do
          create(:tag, name: "old_tag")
          ss = create(:saved_search, query: "old_tag")
          create_bur!("rename old_tag -> new_tag", @admin)

          assert_equal(true, ss.reload.query.split.include?("new_tag"))
        end

        should "not fail if the saved search has too many tags" do
          ss = build(:saved_search, query: SavedSearch::MAX_TAGS.succ.times.map { |n| create(:tag, name: "tag#{n}").name }.join(" "))
          ss.save!(validate: false)

          create_bur!("rename tag0 -> new_tag", @admin)

          assert_equal(true, ss.reload.query.split.include?("new_tag"))
        end
      end
    end
  end
end
