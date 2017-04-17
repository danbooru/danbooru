require 'test_helper'

class RelatedTagQueryTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  context "a related tag query without a category constraint" do
    setup do
      @post_1 = FactoryGirl.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryGirl.create(:post, :tag_string => "aaa bbb ccc")
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
        assert_equal("{\"query\":\"aaa\",\"category\":\"\",\"tags\":[[\"aaa\",0],[\"bbb\",0],[\"ccc\",0]],\"wiki_page_tags\":[]}", @query.to_json)
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
        @wiki_page = FactoryGirl.create(:wiki_page, :title => "aaa", :body => "[[bbb]] [[ccc]]")
        @query = RelatedTagQuery.new("aaa", "")
      end

      should "find any tags embedded in the wiki page" do
        assert_equal(["bbb", "ccc"], @query.wiki_page_tags)
      end
    end
  end

  context "a related tag query with a category constraint" do
    setup do
      @post_1 = FactoryGirl.create(:post, :tag_string => "aaa bbb")
      @post_2 = FactoryGirl.create(:post, :tag_string => "aaa art:ccc")
      @post_3 = FactoryGirl.create(:post, :tag_string => "aaa copy:ddd")
      @query = RelatedTagQuery.new("aaa", "artist")
    end

    should "find the related tags" do
      assert_equal(%w(ccc), @query.tags)
    end
  end
end

