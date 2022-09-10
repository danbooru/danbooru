require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    @builder = FactoryBot.create(:builder_user)
    CurrentUser.user = @builder
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A tag category fetcher" do
    should "fetch for multiple tags" do
      FactoryBot.create(:artist_tag, :name => "aaa")
      FactoryBot.create(:copyright_tag, :name => "bbb")
      categories = Tag.categories_for(%w(aaa bbb ccc))
      assert_equal(Tag.categories.artist, categories["aaa"])
      assert_equal(Tag.categories.copyright, categories["bbb"])
      assert_equal(0, categories["ccc"])
    end
  end

  context "A tag category mapping" do
    should "exist" do
      assert_nothing_raised {Tag.categories}
    end

    should "have convenience methods for the four main categories" do
      assert_equal(0, Tag.categories.general)
      assert_equal(1, Tag.categories.artist)
      assert_equal(3, Tag.categories.copyright)
      assert_equal(4, Tag.categories.character)
      assert_equal(5, Tag.categories.meta)
    end

    should "have a regular expression for matching category names and shortcuts" do
      regexp = Tag.categories.regexp

      assert_match(regexp, "artist")
      assert_match(regexp, "art")
      assert_match(regexp, "copyright")
      assert_match(regexp, "copy")
      assert_match(regexp, "co")
      assert_match(regexp, "character")
      assert_match(regexp, "char")
      assert_match(regexp, "ch")
      assert_match(regexp, "meta")
      assert_no_match(regexp, "c")
      assert_no_match(regexp, "woodle")
    end

    should "map a category name to its value" do
      assert_equal(0, Tag.categories.value_for("general"))
      assert_equal(0, Tag.categories.value_for("gen"))
      assert_equal(1, Tag.categories.value_for("artist"))
      assert_equal(1, Tag.categories.value_for("art"))
      assert_equal(5, Tag.categories.value_for("meta"))
      assert_equal(0, Tag.categories.value_for("unknown"))
    end
  end

  context "A tag" do
    should "know its category name" do
      @tag = FactoryBot.create(:artist_tag)
      assert_equal("Artist", @tag.category_name)
    end

    should "reset its category after updating" do
      tag = FactoryBot.create(:artist_tag)
      assert_equal(Tag.categories.artist, Cache.get("tc:#{Cache.hash(tag.name)}"))

      tag.update!(category: Tag.categories.copyright, updater: create(:user))
      assert_equal(Tag.categories.copyright, Cache.get("tc:#{Cache.hash(tag.name)}"))
    end

    context "not be settable to an invalid category" do
      should validate_inclusion_of(:category).in_array(TagCategory.category_ids)
    end
  end

  context "When a tag is created" do
    should "not create a new version" do
      tag = create(:tag, category: Tag.categories.character)

      assert_equal(0, tag.versions.count)
    end
  end

  context "When a tag is updated" do
    should "create the initial version before the new version" do
      user = create(:user)
      tag = create(:tag, created_at: 1.year.ago, updated_at: 6.months.ago)
      tag.update!(updater: user, category: Tag.categories.character, is_deprecated: true)

      assert_equal(2, tag.versions.count)

      assert_equal(1, tag.first_version.version)
      assert_equal(tag.updated_at_before_last_save.round(4), tag.first_version.created_at.round(4))
      assert_equal(tag.updated_at_before_last_save.round(4), tag.first_version.updated_at.round(4))
      assert_nil(tag.first_version.updater)
      assert_nil(tag.first_version.previous_version)
      assert_equal(Tag.categories.general, tag.first_version.category)
      assert_equal(false, tag.first_version.is_deprecated)

      assert_equal(2, tag.last_version.version)
      assert_equal(user, tag.last_version.updater)
      assert_equal(tag.first_version, tag.last_version.previous_version)
      assert_equal(Tag.categories.character, tag.last_version.category)
      assert_equal(true, tag.last_version.is_deprecated)
    end
  end

  context "When a tag is updated twice by the same user" do
    should "not merge the edits" do
      updated_at = 6.months.ago
      user = create(:user)
      tag = create(:tag, created_at: 1.year.ago, updated_at: updated_at)
      travel_to(1.minute.ago) { tag.update!(updater: user, category: Tag.categories.character, is_deprecated: true) }
      tag.update!(updater: user, category: Tag.categories.copyright)

      assert_equal(3, tag.versions.count)

      assert_equal(1, tag.versions[0].version)
      assert_equal(updated_at.round(4), tag.versions[0].created_at.round(4))
      assert_equal(updated_at.round(4), tag.versions[0].updated_at.round(4))
      assert_nil(tag.versions[0].updater)
      assert_nil(tag.versions[0].previous_version)
      assert_equal(Tag.categories.general, tag.versions[0].category)
      assert_equal(false, tag.versions[0].is_deprecated)

      assert_equal(2, tag.versions[1].version)
      assert_equal(user, tag.versions[1].updater)
      assert_equal(tag.versions[0], tag.versions[1].previous_version)
      assert_equal(Tag.categories.character, tag.versions[1].category)
      assert_equal(true, tag.versions[1].is_deprecated)

      assert_equal(3, tag.versions[2].version)
      assert_equal(user, tag.versions[2].updater)
      assert_equal(tag.versions[1], tag.versions[2].previous_version)
      assert_equal(Tag.categories.copyright, tag.versions[2].category)
      assert_equal(true, tag.versions[2].is_deprecated)
    end
  end

  context "A tag" do
    should "be found when one exists" do
      tag = FactoryBot.create(:tag)
      assert_difference("Tag.count", 0) do
        Tag.find_or_create_by_name(tag.name)
      end
    end

    should "change the type for an existing tag" do
      tag = FactoryBot.create(:tag)
      assert_difference("Tag.count", 0) do
        assert_equal(Tag.categories.general, tag.category)
        Tag.find_or_create_by_name(tag.name, category: "artist", current_user: @builder)
        tag.reload
        assert_equal(Tag.categories.artist, tag.category)
      end
    end

    should "not change category when the tag is too large to be changed by a builder" do
      tag = FactoryBot.create(:tag, post_count: 1001)
      Tag.find_or_create_by_name(tag.name, category: "artist", current_user: @builder)

      assert_equal(0, tag.reload.category)
    end

    should "not change category when the tag is too large to be changed by a member" do
      tag = FactoryBot.create(:tag, post_count: 51)
      Tag.find_or_create_by_name(tag.name, category: "artist", current_user: create(:member_user))

      assert_equal(0, tag.reload.category)
    end

    should "update post tag counts when the category is changed" do
      post = FactoryBot.create(:post, tag_string: "test")
      assert_equal(1, post.tag_count_general)
      assert_equal(0, post.tag_count_character)

      tag = Tag.find_or_create_by_name("test", category: "char", current_user: @builder)
      post.reload
      assert_equal(0, post.tag_count_general)
      assert_equal(1, post.tag_count_character)
    end

    should "be created when one doesn't exist" do
      assert_difference("Tag.count", 1) do
        tag = Tag.find_or_create_by_name("hoge")
        assert_equal("hoge", tag.name)
        assert_equal(Tag.categories.general, tag.category)
      end
    end

    should "be created with the type when one doesn't exist" do
      assert_difference("Tag.count", 1) do
        tag = Tag.find_or_create_by_name("hoge", category: "artist", current_user: @builder)
        assert_equal("hoge", tag.name)
        assert_equal(Tag.categories.artist, tag.category)
      end
    end

    should "parse tag names into words" do
      assert_equal(%w[very long hair], Tag.new(name: "very_long_hair").words)

      assert_equal(%w[k - on !], Tag.split_words("k-on!"))
      assert_equal(%w[. hack //], Tag.split_words(".hack//"))
      assert_equal(%w[re : zero], Tag.split_words("re:zero"))
      assert_equal(%w[# compass], Tag.split_words("#compass"))
      assert_equal(%w[. hack // g . u .], Tag.split_words(".hack//g.u."))
      assert_equal(%w[me ! me ! me !], Tag.split_words("me!me!me!"))
      assert_equal(%w[d . gray - man], Tag.split_words("d.gray-man"))
      assert_equal(%w[steins ; gate], Tag.split_words("steins;gate"))
      assert_equal(%w[tiger _&_ bunny], Tag.split_words("tiger_&_bunny"))
      assert_equal(%w[ssss . gridman], Tag.split_words("ssss.gridman"))
      assert_equal(%w[yu - gi - oh !_ 5d's], Tag.split_words("yu-gi-oh!_5d's"))
      assert_equal(%w[don't _ say _" lazy "], Tag.split_words(%q{don't_say_"lazy"}))
      assert_equal(%w[jack - o '- lantern], Tag.split_words("jack-o'-lantern"))
      assert_equal(%w[d . va _( overwatch )], Tag.split_words("d.va_(overwatch)"))
      assert_equal(%w[rosario + vampire], Tag.split_words("rosario+vampire"))
      assert_equal(%w[girls '_ frontline], Tag.split_words("girls'_frontline"))
      assert_equal(%w[fate / grand _ order], Tag.split_words("fate/grand_order"))
      assert_equal(%w[yorha _ no ._ 2 _ type _ b], Tag.split_words("yorha_no._2_type_b"))
      assert_equal(%w[love _ live !_ sunshine !!], Tag.split_words("love_live!_sunshine!!"))
      assert_equal(%w[jeanne _ d'arc _ alter _( ver ._ shinjuku _ 1999 )_( fate )], Tag.split_words("jeanne_d'arc_alter_(ver._shinjuku_1999)_(fate)"))
      assert_equal(%w[kaguya - sama _ wa _ kokurasetai _~ tensai - tachi _ no _ renai _ zunousen ~], Tag.split_words("kaguya-sama_wa_kokurasetai_~tensai-tachi_no_renai_zunousen~"))

      assert_equal(%w[k on], Tag.new(name: "k-on!").words)
      assert_equal(%w[hack], Tag.new(name: ".hack//").words)
      assert_equal(%w[nyoro~n], Tag.new(name: "nyoro~n").words)
      assert_equal(%w[re zero], Tag.new(name: "re:zero").words)
      assert_equal(%w[compass], Tag.new(name: "#compass").words)
      assert_equal(%w[hack g u], Tag.new(name: ".hack//g.u.").words)
      assert_equal(%w[me me me], Tag.new(name: "me!me!me!").words)
      assert_equal(%w[d gray man], Tag.new(name: "d.gray-man").words)
      assert_equal(%w[steins gate], Tag.new(name: "steins;gate").words)
      assert_equal(%w[tiger bunny], Tag.new(name: "tiger_&_bunny").words)
      assert_equal(%w[ssss gridman], Tag.new(name: "ssss.gridman").words)
      assert_equal(%w[yu gi oh 5d's], Tag.new(name: "yu-gi-oh!_5d's").words)
      assert_equal(%w[don't say lazy], Tag.new(name: %q{don't_say_"lazy"}).words)
      assert_equal(%w[jack o lantern], Tag.new(name: "jack-o'-lantern").words)
      assert_equal(%w[d va overwatch], Tag.new(name: "d.va_(overwatch)").words)
      assert_equal(%w[rosario vampire], Tag.new(name: "rosario+vampire").words)
      assert_equal(%w[girls frontline], Tag.new(name: "girls'_frontline").words)
      assert_equal(%w[fate grand order], Tag.new(name: "fate/grand_order").words)
      assert_equal(%w[yorha no 2 type b], Tag.new(name: "yorha_no._2_type_b").words)
      assert_equal(%w[love live sunshine], Tag.new(name: "love_live!_sunshine!!").words)
      assert_equal(%w[jeanne d'arc alter ver shinjuku 1999 fate], Tag.new(name: "jeanne_d'arc_alter_(ver._shinjuku_1999)_(fate)").words)
      assert_equal(%w[kaguya sama wa kokurasetai tensai tachi no renai zunousen], Tag.new(name: "kaguya-sama_wa_kokurasetai_~tensai-tachi_no_renai_zunousen~").words)

      assert_equal(%w[:o], Tag.new(name: ":o").words)
      assert_equal(%w[o_o], Tag.new(name: "o_o").words)
      assert_equal(%w[^_^], Tag.new(name: "^_^").words)
      assert_equal(%w[^^^], Tag.new(name: "^^^").words)
      assert_equal(%w[c.c.], Tag.new(name: "c.c.").words)
      assert_equal(%w[\||/], Tag.new(name: '\||/').words)
      assert_equal(%w[\(^o^)/], Tag.new(name: '\(^o^)/').words)
      assert_equal(%w[<o>_<o>], Tag.new(name: "<o>_<o>").words)
      assert_equal(%w[<|>_<|>], Tag.new(name: "<|>_<|>").words)
      assert_equal(%w[k-----s], Tag.new(name: "k-----s").words)
      assert_equal(%w[m.u.g.e.n], Tag.new(name: "m.u.g.e.n").words)
    end

    context "during name validation" do
      # tags with spaces or uppercase are allowed because they are normalized
      # to lowercase with underscores.
      should allow_value(" foo ").for(:name).on(:create)
      should allow_value("foo bar").for(:name).on(:create)
      should allow_value("FOO").for(:name).on(:create)

      should allow_value(":)").for(:name).on(:create)
      should allow_value(":(").for(:name).on(:create)
      should allow_value(";)").for(:name).on(:create)
      should allow_value(";(").for(:name).on(:create)
      should allow_value(">:)").for(:name).on(:create)
      should allow_value(">:(").for(:name).on(:create)

      should allow_value("foo_(bar)").for(:name).on(:create)
      should allow_value("foo_(bar_(baz))").for(:name).on(:create)

      should_not allow_value("").for(:name).on(:create)
      should_not allow_value("___").for(:name).on(:create)
      should_not allow_value("~foo").for(:name).on(:create)
      should_not allow_value("-foo").for(:name).on(:create)
      should_not allow_value("/foo").for(:name).on(:create)
      should_not allow_value("`foo").for(:name).on(:create)
      should_not allow_value("%foo").for(:name).on(:create)
      should_not allow_value("(foo").for(:name).on(:create)
      should_not allow_value(")foo").for(:name).on(:create)
      should_not allow_value("{foo").for(:name).on(:create)
      should_not allow_value("}foo").for(:name).on(:create)
      should_not allow_value("]foo").for(:name).on(:create)
      should_not allow_value("_foo").for(:name).on(:create)
      should_not allow_value("foo_").for(:name).on(:create)
      should_not allow_value("foo__bar").for(:name).on(:create)
      should_not allow_value("foo*bar").for(:name).on(:create)
      should_not allow_value("foo,bar").for(:name).on(:create)
      should_not allow_value("foo\abar").for(:name).on(:create)
      should_not allow_value("café").for(:name).on(:create)
      should_not allow_value("東方").for(:name).on(:create)
      should_not allow_value("FAV:blah").for(:name).on(:create)
      should_not allow_value("X"*171).for(:name).on(:create)

      should_not allow_value("foo)").for(:name).on(:create)
      should_not allow_value("foo(").for(:name).on(:create)
      should_not allow_value("foo)(").for(:name).on(:create)
      should_not allow_value("foo(()").for(:name).on(:create)
      should_not allow_value("foo())").for(:name).on(:create)

      metatags = PostQueryBuilder::METATAGS + TagCategory.mapping.keys
      metatags.each do |metatag|
        should_not allow_value("#{metatag}:foo").for(:name).on(:create)
      end

      context "a cosplay tag" do
        setup do
          create(:tag, name: "bkub", category: Tag.categories.artist)
          create(:tag, name: "fumimi", category: Tag.categories.character)
          create(:tag_alias, antecedent_name: "orin", consequent_name: "kaenbyou_rin")
        end

        should allow_value("fumimi_(cosplay)").for(:name)
        should allow_value("new_tag_(cosplay)").for(:name)
        should_not allow_value("bkub_(cosplay)").for(:name)
        should_not allow_value("orin_(cosplay)").for(:name)
      end
    end
  end
end
