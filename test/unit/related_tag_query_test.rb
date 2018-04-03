require 'test_helper'

class RelatedTagQueryTest < ActiveSupport::TestCase
  setup do
    user = FactoryBot.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "#other_wiki_category_tags" do
    subject { RelatedTagQuery.new("copyright") }

    setup do
      @copyright = FactoryBot.create(:copyright_tag, name: "copyright")
      @wiki = FactoryBot.create(:wiki_page, title: "copyright", body: "[[list_of_hoges]]")
      @list_of_hoges = FactoryBot.create(:wiki_page, title: "list_of_hoges", body: "[[alpha]] and [[beta]]")
    end

    should "return tags from the associated list wiki" do
      result = subject.other_wiki_category_tags
      assert_not_nil(result[0])
      assert_not_nil(result[0]["wiki_page_tags"])
      assert_equal(%w(alpha beta), result[0]["wiki_page_tags"].map(&:first))
    end
  end

  context "a related tag query without a category constraint" do
    setup do
      @post_1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryBot.create(:post, :tag_string => "aaa bbb ccc")
    end

    context "for a tag that already exists" do
      setup do
        Tag.named("aaa").first.update_related
        @query = RelatedTagQuery.new("aaa", "")
      end

      should "work" do
        assert_equal(["aaa", "bbb", "ccc"], @query.tags)
      end

      should "render the json" do
        assert_equal("{\"query\":\"aaa\",\"category\":\"\",\"tags\":[[\"aaa\",0],[\"bbb\",0],[\"ccc\",0]],\"wiki_page_tags\":[],\"other_wikis\":[]}", @query.to_json)
      end
    end

    context "for a tag that doesn't exist" do
      setup do
        @query = RelatedTagQuery.new("zzz", "")
      end

      should "work" do
        assert_equal([], @query.tags)
      end
    end

    context "for an aliased tag" do
      setup do
        @ta = FactoryBot.create(:tag_alias, antecedent_name: "xyz", consequent_name: "aaa")
        @wp = FactoryBot.create(:wiki_page, title: "aaa", body: "blah [[foo|blah]] [[FOO]] [[bar]] blah")
        @query = RelatedTagQuery.new("xyz", "")

        Tag.named("aaa").first.update_related
      end

      should "take wiki tags from the consequent's wiki" do
        assert_equal(%w[foo bar], @query.wiki_page_tags)
      end

      should "take related tags from the consequent tag" do
        assert_equal(%w[aaa bbb ccc], @query.tags)
      end
    end

    context "for a pattern search" do
      setup do
        @query = RelatedTagQuery.new("a*", "")
      end

      should "work" do
        assert_equal(["aaa"], @query.tags)
      end
    end

    context "for a tag with a wiki page" do
      setup do
        @wiki_page = FactoryBot.create(:wiki_page, :title => "aaa", :body => "[[bbb]] [[ccc]]")
        @query = RelatedTagQuery.new("aaa", "")
      end

      should "find any tags embedded in the wiki page" do
        assert_equal(["bbb", "ccc"], @query.wiki_page_tags)
      end
    end
  end

  context "a related tag query with a category constraint" do
    setup do
      @post_1 = FactoryBot.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryBot.create(:post, :tag_string => "aaa art:ccc")
      @post_3 = FactoryBot.create(:post, :tag_string => "aaa copy:ddd")
      @query = RelatedTagQuery.new("aaa", "artist")
    end

    should "find the related tags" do
      assert_equal(%w(ccc), @query.tags)
    end
  end
end

