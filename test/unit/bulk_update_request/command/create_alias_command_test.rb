require "test_helper"

class CreateAliasCommandTest < ActiveSupport::TestCase
  setup do
    @admin = create(:admin_user)
    CurrentUser.user = @admin
  end

  teardown do
    CurrentUser.user = nil
  end

  context "the create alias command" do
    context "on creation" do
      should "fail if the alias is invalid" do
        create(:tag_alias, antecedent_name: "bbb", consequent_name: "ccc")

        assert_invalid_bur(
          script: "create alias aaa -> bbb",
          errors: ["Can't create alias [[aaa]] -> [[bbb]] (bbb is already aliased to ccc)"],
        )
      end

      should "fail if the antecedent name is invalid" do
        assert_invalid_bur(
          script: "create alias tag_ -> tag",
          errors: ["Can't create alias [[tag_]] -> [[tag]] ('tag_' cannot end with an underscore)"],
        )
      end

      should "fail if the consequent name is invalid" do
        assert_invalid_bur(
          script: "create alias tag -> tag_",
          errors: ["Can't create alias [[tag]] -> [[tag_]] ('tag_' cannot end with an underscore)"],
        )
      end

      should "fail if the consequent name contains a tag type prefix" do
        assert_invalid_bur(
          script: "alias blah -> char:bar",
          errors: ["Can't create alias [[blah]] -> [[char:bar]] ('char:bar' cannot begin with 'char:')"],
        )
      end
    end

    context "on approval" do
      should "create an alias" do
        create(:wiki_page, title: "foo")
        create(:artist, name: "foo")
        @bur = create_bur!("create alias foo -> bar", @admin)

        @alias = TagAlias.find_by(antecedent_name: "foo", consequent_name: "bar")
        assert_equal(true, @alias.present?)
        assert_equal(true, @alias.is_active?)
        assert_equal("approved", @bur.reload.status)
      end

      should "rename the aliased tag's artist entry and wiki page" do
        @wiki = create(:wiki_page, title: "foo")
        @artist = create(:artist, name: "foo")
        create_bur!("create alias foo -> bar", @admin)

        assert_equal("bar", @artist.reload.name)
        assert_equal("bar", @wiki.reload.title)
      end

      should "move any active aliases from the old tag to the new tag" do
        create_bur!("alias aaa -> bbb", @admin)
        create_bur!("alias bbb -> ccc", @admin)

        assert_equal(false, TagAlias.exists?(antecedent_name: "aaa", consequent_name: "bbb", status: "active"))
        assert_equal(true, TagAlias.exists?(antecedent_name: "bbb", consequent_name: "ccc", status: "active"))
        assert_equal(true, TagAlias.exists?(antecedent_name: "aaa", consequent_name: "ccc", status: "active"))
      end

      should "move any active implications from the old tag to the new tag" do
        create_bur!("imply aaa -> bbb", @admin)
        create_bur!("alias bbb -> ccc", @admin)

        assert_equal(false, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "bbb", status: "active"))
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "ccc", status: "active"))

        create_bur!("alias aaa -> ddd", @admin)

        assert_equal(false, TagImplication.active.exists?(antecedent_name: "aaa", consequent_name: "ccc", status: "active"))
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "ddd", consequent_name: "ccc", status: "active"))
      end

      should "not fail when merging two tags that imply the same parent tag" do
        create(:tag_implication, antecedent_name: "bird_on_finger", consequent_name: "bird")
        create(:tag_implication, antecedent_name: "bird_on_hand", consequent_name: "bird")

        create_bur!("alias bird_on_finger -> bird_on_hand", @admin)

        assert_equal(false, TagImplication.active.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird"))
        assert_equal(true, TagImplication.deleted.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird"))
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "bird_on_hand", consequent_name: "bird"))
        assert_equal(true, TagAlias.active.exists?(antecedent_name: "bird_on_finger", consequent_name: "bird_on_hand"))
      end

      should "not fail when merging two tags implied by the same child tag" do
        create(:tag_implication, antecedent_name: "spider", consequent_name: "insect")
        create(:tag_implication, antecedent_name: "spider", consequent_name: "bug")

        create_bur!("alias insect -> bug", @admin)

        assert_equal(false, TagImplication.active.exists?(antecedent_name: "spider", consequent_name: "insect"))
        assert_equal(true, TagImplication.deleted.exists?(antecedent_name: "spider", consequent_name: "insect"))
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "spider", consequent_name: "bug"))
        assert_equal(true, TagAlias.active.exists?(antecedent_name: "insect", consequent_name: "bug"))
      end

      should "allow moving a copyright tag that implies another copyright tag" do
        create(:tag, name: "komeiji_koishi's_heart_throbbing_adventure", category: Tag.categories.general)
        create(:tag, name: "komeiji_koishi_no_dokidoki_daibouken", category: Tag.categories.copyright)
        create(:tag, name: "touhou", category: Tag.categories.copyright)
        create(:tag_implication, antecedent_name: "komeiji_koishi_no_dokidoki_daibouken", consequent_name: "touhou")

        create_bur!("alias komeiji_koishi_no_dokidoki_daibouken -> komeiji_koishi's_heart_throbbing_adventure", @admin)

        assert_equal(true, Tag.find_by_name("komeiji_koishi's_heart_throbbing_adventure").copyright?)
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "komeiji_koishi's_heart_throbbing_adventure", consequent_name: "touhou"))
      end

      should "allow aliases to be reversed in one step" do
        @alias = create(:tag_alias, antecedent_name: "aaa", consequent_name: "bbb")
        create_bur!("create alias bbb -> aaa", @admin)

        assert_equal(true, @alias.reload.is_deleted?)
        assert_equal(true, TagAlias.active.exists?(antecedent_name: "bbb", consequent_name: "aaa"))
      end

      should "allow aliasing together two tags with the same implication" do
        ti1 = create(:tag_implication, antecedent_name: "gigantamax_flapple", consequent_name: "gigantamax")
        ti2 = create(:tag_implication, antecedent_name: "gigantamax_appletun", consequent_name: "gigantamax")
        create_bur!("alias gigantamax_flapple -> gigantamax_flapple/appletun\nalias gigantamax_appletun -> gigantamax_flapple/appletun", @admin)

        assert_equal(true, TagAlias.active.exists?(antecedent_name: "gigantamax_flapple", consequent_name: "gigantamax_flapple/appletun"))
        assert_equal(true, TagAlias.active.exists?(antecedent_name: "gigantamax_appletun", consequent_name: "gigantamax_flapple/appletun"))
        assert_equal(true, TagImplication.active.exists?(antecedent_name: "gigantamax_flapple/appletun", consequent_name: "gigantamax"))
        assert_equal(false, TagImplication.active.exists?(antecedent_name: "gigantamax_flapple", consequent_name: "gigantamax"))
        assert_equal(false, TagImplication.active.exists?(antecedent_name: "gigantamax_appletun", consequent_name: "gigantamax"))
        assert_equal("deleted", ti1.reload.status)
        assert_equal("deleted", ti2.reload.status)
      end

      should "be case-insensitive" do
        create_bur!("CREATE ALIAS AAA -> BBB", @admin)

        @alias = TagAlias.find_by(antecedent_name: "aaa", consequent_name: "bbb")
        assert_equal(true, @alias.present?)
        assert_equal(true, @alias.is_active?)
      end

      context "when aliasing a character tag with a *_(cosplay) tag" do
        should "move the *_(cosplay) tag as well" do
          @post = create(:post, tag_string: "toosaka_rin_(cosplay)")
          @wiki = create(:wiki_page, title: "toosaka_rin_(cosplay)")

          create_bur!("alias toosaka_rin -> tohsaka_rin", @admin)

          assert_equal("cosplay tohsaka_rin tohsaka_rin_(cosplay)", @post.reload.tag_string)
          assert_equal("tohsaka_rin_(cosplay)", @wiki.reload.title)
        end
      end

      context "when rewriting wiki pages" do
        should "rewrite wiki pages to use the new tag" do
          @wiki = create(:wiki_page, body: "[[aaa]] bar")

          create_bur!("alias aaa -> bbb", @admin)

          assert_equal("[[bbb]] bar", @wiki.reload.body)
        end

        should "not fail to rewrite wiki pages if the body is too long" do
          @wiki = build(:wiki_page, title: "foo", body: "[[aaa]] bar #{"x" * WikiPage::MAX_WIKI_LENGTH}")
          @wiki.save!(validate: false)

          create_bur!("alias aaa -> bbb", @admin)

          assert_equal("[[bbb]] bar #{"x" * WikiPage::MAX_WIKI_LENGTH}", @wiki.reload.body)
        end
      end

      context "when rewriting pool descriptions" do
        should "rewrite pool descriptions to use the new tag" do
          @pool = create(:pool, description: "foo [[aaa]] bar")

          create_bur!("alias aaa -> bbb", @admin)

          assert_equal("foo [[bbb]] bar", @pool.reload.description)
        end

        should "not fail to rewrite pool descriptions if the pool description is too long" do
          @pool = build(:pool, description: "foo [[aaa]] bar #{"x" * Pool::MAX_DESCRIPTION_LENGTH}")
          @pool.save!(validate: false)

          create_bur!("alias aaa -> bbb", @admin)

          assert_equal("foo [[bbb]] bar #{"x" * Pool::MAX_DESCRIPTION_LENGTH}", @pool.reload.description)
        end
      end

      context "when moving blacklisted tags" do
        should "move blacklisted tags" do
          user = create(:user, blacklisted_tags: "old_tag")
          create_bur!("alias old_tag -> new_tag", @admin)

          assert_equal(true, user.reload.blacklisted_tags.split.include?("new_tag"))
        end

        should "not fail if the user has too many blacklisted tags" do
          user = build(:user, blacklisted_tags: User::MAX_BLACKLIST_TAGS.succ.times.map { |n| "tag#{n}" }.join("\n"))
          user.save!(validate: false)

          create_bur!("alias tag0 -> new_tag", @admin)

          assert_equal(true, user.reload.blacklisted_tags.split.include?("new_tag"))
        end
      end

      context "when moving saved searches" do
        should "move saved searches" do
          create(:tag, name: "old_tag")
          ss = create(:saved_search, query: "old_tag")
          create_bur!("alias old_tag -> new_tag", @admin)

          assert_equal(true, ss.reload.query.split.include?("new_tag"))
        end

        should "not fail if the saved search has too many tags" do
          ss = build(:saved_search, query: SavedSearch::MAX_TAGS.succ.times.map { |n| create(:tag, name: "tag#{n}").name }.join(" "))
          ss.save!(validate: false)

          create_bur!("alias tag0 -> new_tag", @admin)

          assert_equal(true, ss.reload.query.split.include?("new_tag"))
        end
      end
    end
  end
end
