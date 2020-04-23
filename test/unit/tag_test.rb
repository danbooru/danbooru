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
    should "fetch for a single tag" do
      FactoryBot.create(:artist_tag, :name => "test")
      assert_equal(Tag.categories.artist, Tag.category_for("test"))
    end

    should "fetch for a single tag with strange markup" do
      FactoryBot.create(:artist_tag, :name => "!@$%")
      assert_equal(Tag.categories.artist, Tag.category_for("!@$%"))
    end

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

      tag.update_attribute(:category, Tag.categories.copyright)
      assert_equal(Tag.categories.copyright, Cache.get("tc:#{Cache.hash(tag.name)}"))
    end

    context "not be settable to an invalid category" do
      should validate_inclusion_of(:category).in_array(TagCategory.category_ids)
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
        Tag.find_or_create_by_name("artist:#{tag.name}")
        tag.reload
        assert_equal(Tag.categories.artist, tag.category)
      end
    end

    should "not change the category is the tag is locked" do
      tag = FactoryBot.create(:tag, :is_locked => true)
      assert_equal(true, tag.is_locked?)
      Tag.find_or_create_by_name("artist:#{tag.name}")
      tag.reload
      assert_equal(0, tag.category)
    end

    should "not change category when the tag is too large to be changed by a builder" do
      tag = FactoryBot.create(:tag, post_count: 1001)
      Tag.find_or_create_by_name("artist:#{tag.name}", creator: @builder)

      assert_equal(0, tag.reload.category)
    end

    should "not change category when the tag is too large to be changed by a member" do
      tag = FactoryBot.create(:tag, post_count: 51)
      Tag.find_or_create_by_name("artist:#{tag.name}", creator: FactoryBot.create(:member_user))

      assert_equal(0, tag.reload.category)
    end

    should "update post tag counts when the category is changed" do
      post = FactoryBot.create(:post, tag_string: "test")
      assert_equal(1, post.tag_count_general)
      assert_equal(0, post.tag_count_character)

      tag = Tag.find_or_create_by_name("char:test")
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
        tag = Tag.find_or_create_by_name("artist:hoge")
        assert_equal("hoge", tag.name)
        assert_equal(Tag.categories.artist, tag.category)
      end
    end

    context "during name validation" do
      # tags with spaces or uppercase are allowed because they are normalized
      # to lowercase with underscores.
      should allow_value(" foo ").for(:name).on(:create)
      should allow_value("foo bar").for(:name).on(:create)
      should allow_value("FOO").for(:name).on(:create)

      should_not allow_value("").for(:name).on(:create)
      should_not allow_value("___").for(:name).on(:create)
      should_not allow_value("~foo").for(:name).on(:create)
      should_not allow_value("-foo").for(:name).on(:create)
      should_not allow_value("_foo").for(:name).on(:create)
      should_not allow_value("foo_").for(:name).on(:create)
      should_not allow_value("foo__bar").for(:name).on(:create)
      should_not allow_value("foo*bar").for(:name).on(:create)
      should_not allow_value("foo,bar").for(:name).on(:create)
      should_not allow_value("foo\abar").for(:name).on(:create)
      should_not allow_value("café").for(:name).on(:create)
      should_not allow_value("東方").for(:name).on(:create)
      should_not allow_value("FAV:blah").for(:name).on(:create)

      metatags = PostQueryBuilder::METATAGS + TagCategory.mapping.keys
      metatags.each do |metatag|
        should_not allow_value("#{metatag}:foo").for(:name).on(:create)
      end

      context "a cosplay tag" do
        setup do
          create(:tag, name: "bkub", category: Tag.categories.artist)
          create(:tag, name: "fumimi", category: Tag.categories.character)
        end

        should allow_value("fumimi_(cosplay)").for(:name)
        should allow_value("new_tag_(cosplay)").for(:name)
        should_not allow_value("bkub_(cosplay)").for(:name)
      end
    end
  end

  context "A tag with an incorrect post count" do
    should "be fixed" do
      tag1 = FactoryBot.create(:tag, name: "touhou", post_count: -10)
      tag2 = FactoryBot.create(:tag, name: "bkub", post_count: 10)
      tag3 = FactoryBot.create(:tag, name: "chen", post_count: 10)
      post = FactoryBot.create(:post, tag_string: "touhou bkub")

      tags = Tag.regenerate_post_counts!
      assert_equal(3, tags.size)
      assert_equal(1, tag1.reload.post_count)
      assert_equal(1, tag2.reload.post_count)
      assert_equal(0, tag3.reload.post_count)
    end
  end
end
