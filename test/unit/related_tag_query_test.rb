require 'test_helper'

class RelatedTagQueryTest < ActiveSupport::TestCase
  setup do
    user = FactoryBot.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "#other_wiki_pages" do
    subject { RelatedTagQuery.new(query: "copyright") }

    setup do
      create(:tag, name: "alpha", post_count: 1)
      create(:tag, name: "beta", post_count: 1)
      @copyright = FactoryBot.create(:copyright_tag, name: "copyright")
      @wiki = FactoryBot.create(:wiki_page, title: "copyright", body: "[[list_of_hoges]]")
      @list_of_hoges = FactoryBot.create(:wiki_page, title: "list_of_hoges", body: "[[alpha]] and [[beta]]")
    end

    should "return tags from the associated list wiki" do
      result = subject.other_wiki_pages
      assert_not_nil(result[0])
      assert_equal(%w(alpha beta), result[0].tags)
    end
  end

  context "a related tag query without a category constraint" do
    setup do
      @post_1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
    end

    context "for a tag that already exists" do
      setup do
        @query = RelatedTagQuery.new(query: "aaa")
      end

      should "work" do
        assert_equal(["aaa", "bbb", "ccc"], @query.tags.map(&:name))
      end
    end

    context "for a tag that doesn't exist" do
      setup do
        @query = RelatedTagQuery.new(query: "zzz")
      end

      should "work" do
        assert_equal(true, @query.tags.empty?)
      end
    end

    context "for an aliased tag" do
      setup do
        create(:tag, name: "foo", post_count: 42)
        @ta = FactoryBot.create(:tag_alias, antecedent_name: "xyz", consequent_name: "aaa")
        @wp = FactoryBot.create(:wiki_page, title: "aaa", body: "blah [[foo|blah]] [[FOO]] [[does not exist]] blah")
        @query = RelatedTagQuery.new(query: "xyz")
      end

      should "take wiki tags from the consequent's wiki" do
        assert_equal(%w[foo], @query.wiki_page_tags)
      end

      should "take related tags from the consequent tag" do
        assert_equal(%w[aaa bbb ccc], @query.tags.map(&:name))
      end
    end

    context "for a pattern search" do
      setup do
        @query = RelatedTagQuery.new(query: "a*")
      end

      should "work" do
        assert_equal(["aaa"], @query.tags.map(&:name))
      end
    end

    context "for a tag with a wiki page" do
      setup do
        @wiki_page = FactoryBot.create(:wiki_page, :title => "aaa", :body => "[[bbb]] [[ccc]]")
        @query = RelatedTagQuery.new(query: "aaa")
      end

      should "find any tags embedded in the wiki page" do
        assert_equal(["bbb", "ccc"], @query.wiki_page_tags)
      end

      should "return the tags in the same order as given by the wiki" do
        create(:wiki_page, title: "wiki", body: "[[ccc]] [[bbb]] [[ccc]] [[bbb]] [[aaa]]")

        query = RelatedTagQuery.new(query: "wiki")
        assert_equal(%w[ccc bbb aaa], query.wiki_page_tags)
      end

      should "return aliased tags" do
        create(:tag_alias, antecedent_name: "kitten", consequent_name: "cat", status: "active")
        create(:wiki_page, title: "wiki", body: "[[kitten]]")

        query = RelatedTagQuery.new(query: "wiki")
        assert_equal(%w[cat], query.wiki_page_tags)
      end
    end
  end

  context "a related tag query with a category constraint" do
    setup do
      @post_1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryBot.create(:post, :tag_string => "aaa art:ccc")
      @post_3 = FactoryBot.create(:post, :tag_string => "aaa copy:ddd")
      @query = RelatedTagQuery.new(query: "aaa", category: "artist")
    end

    should "find the related tags" do
      assert_equal(["ccc"], @query.tags.map(&:name))
    end
  end
end
