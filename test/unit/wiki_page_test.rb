require 'test_helper'

class WikiPageTest < ActiveSupport::TestCase
  teardown do
    CurrentUser.user = nil
  end

  context "A wiki page" do
    context "updated by a regular user" do
      setup do
        @user = FactoryBot.create(:user)
        CurrentUser.user = @user
        @wiki_page = FactoryBot.create(:wiki_page, :title => "HOT POTATO", :other_names => "foo*bar baz")
      end

      should "search by title" do
        matches = WikiPage.titled("hot potato")
        assert_equal(1, matches.count)
        assert_equal("hot_potato", matches.first.title)
      end

      should "search other names with wildcards" do
        assert_search_equals(@wiki_page, other_names_match: "fo*")
      end

      should "create versions" do
        assert_difference("WikiPageVersion.count") do
          @wiki_page = FactoryBot.create(:wiki_page, :title => "xxx")
        end

        assert_difference("WikiPageVersion.count") do
          @wiki_page.title = "yyy"
          travel(1.day) do
            @wiki_page.save
          end
        end
      end

      should "revert to a prior version" do
        @wiki_page.title = "yyy"
        travel(1.day) do
          @wiki_page.save
        end
        version = WikiPageVersion.first
        @wiki_page.revert_to!(version)
        @wiki_page.reload
        assert_equal("hot_potato", @wiki_page.title)
      end

      should "update its dtext links" do
        @wiki_page.update!(body: "[[long hair]]")
        assert_equal(1, @wiki_page.dtext_links.size)
        assert_equal("wiki_link", @wiki_page.dtext_links.first.link_type)
        assert_equal("long_hair", @wiki_page.dtext_links.first.link_target)

        @wiki_page.update!(body: "http://www.google.com")
        assert_equal(1, @wiki_page.dtext_links.size)
        assert_equal("external_link", @wiki_page.dtext_links.first.link_type)
        assert_equal("http://www.google.com", @wiki_page.dtext_links.first.link_target)

        @wiki_page.update!(body: "nothing")
        assert_equal(0, @wiki_page.dtext_links.size)
      end
    end

    context "the wiki body" do
      should "be normalized to NFC" do
        # \u00E9: é; \u0301: acute accent
        @wiki = create(:wiki_page, body: "Poke\u0301mon")
        assert_equal("Pok\u00E9mon", @wiki.body)
      end

      should "normalize line endings and trim spaces" do
        @wiki = create(:wiki_page, body: " foo\nbar\n")
        assert_equal("foo\r\nbar", @wiki.body)
      end
    end

    context "the #normalize_other_names method" do
      subject { build(:wiki_page) }

      should normalize_attribute(:other_names).from(["   foo"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo   "]).to(["foo"])
      should normalize_attribute(:other_names).from(["___foo"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo___"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo\n"]).to(["foo"])
      should normalize_attribute(:other_names).from(["foo bar"]).to(["foo_bar"])
      should normalize_attribute(:other_names).from(["foo   bar"]).to(["foo_bar"])
      should normalize_attribute(:other_names).from(["foo___bar"]).to(["foo_bar"])
      should normalize_attribute(:other_names).from([" _Foo Bar_ "]).to(["Foo_Bar"])
      should normalize_attribute(:other_names).from(["foo 1", "bar 2"]).to(["foo_1", "bar_2"])
      should normalize_attribute(:other_names).from(["foo", nil, "", " ", "bar"]).to(["foo", "bar"])
      should normalize_attribute(:other_names).from([nil, "", " "]).to([])
      should normalize_attribute(:other_names).from(["pokémon".unicode_normalize(:nfd)]).to(["pokémon".unicode_normalize(:nfkc)])
      should normalize_attribute(:other_names).from(["ＡＢＣ"]).to(["ABC"])
      should normalize_attribute(:other_names).from(["foo", "foo"]).to(["foo"])
      should normalize_attribute(:other_names).from(%w[foo*bar baz baz 加賀（艦これ）]).to(%w[foo*bar baz 加賀(艦これ)])

      should normalize_attribute(:other_names).from("foo foo").to(["foo"])
      should normalize_attribute(:other_names).from("foo bar").to(["foo", "bar"])
      should normalize_attribute(:other_names).from("_foo_ Bar").to(["foo", "Bar"])
    end

    context "during title validation" do
      should normalize_attribute(:title).from(" foo ").to("foo")
      should normalize_attribute(:title).from("~foo").to("foo")
      should normalize_attribute(:title).from("_foo").to("foo")
      should normalize_attribute(:title).from("foo_").to("foo")
      should normalize_attribute(:title).from("FOO").to("foo")
      should normalize_attribute(:title).from("foo__bar").to("foo_bar")
      should normalize_attribute(:title).from("foo___bar").to("foo_bar")
      should normalize_attribute(:title).from("___foo___bar___").to("foo_bar")
      should normalize_attribute(:title).from("foo bar").to("foo_bar")
      should normalize_attribute(:title).from(" Foo___   Bar ").to("foo_bar")

      should_not allow_value("").for(:title).on(:create)
      should_not allow_value("___").for(:title).on(:create)
      should_not allow_value("-foo").for(:title).on(:create)
      should_not allow_value("/foo").for(:title).on(:create)
      should_not allow_value("foo*bar").for(:title).on(:create)
      should_not allow_value("foo,bar").for(:title).on(:create)
      should_not allow_value("foo\abar").for(:title).on(:create)
      should_not allow_value("café").for(:title).on(:create)
      should_not allow_value("東方").for(:title).on(:create)
      should_not allow_value("FAV:blah").for(:title).on(:create)
      should_not allow_value("X"*171).for(:title).on(:create)
    end

    context "with other names" do
      should "not allow artist wikis to have other names" do
        tag = create(:artist_tag)
        wiki = build(:wiki_page, title: tag.name, other_names: ["blah"])

        assert_equal(false, wiki.valid?)
        assert_equal(["An artist wiki can't have other names"], wiki.errors[:base])
      end
    end
  end
end
