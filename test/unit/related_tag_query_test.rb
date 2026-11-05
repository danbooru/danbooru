require "test_helper"

class RelatedTagQueryTest < ActiveSupport::TestCase
  context "a related tag query without a category constraint" do
    setup do
      create(:post, tag_string: "aaa bbb")
      create(:post, tag_string: "aaa bbb ccc")
    end

    context "for a tag that already exists" do
      setup do
        @query = RelatedTagQuery.new(query: "aaa")
      end

      should "work" do
        assert_equal(["aaa", "bbb", "ccc"], @query.related_tags.map(&:name))
      end
    end

    context "for a tag that doesn't exist" do
      setup do
        @query = RelatedTagQuery.new(query: "zzz")
      end

      should "work" do
        assert_equal(true, @query.related_tags.empty?)
      end
    end

    context "for an aliased tag" do
      setup do
        create(:tag, name: "foo", post_count: 42)
        @ta = create(:tag_alias, antecedent_name: "xyz", consequent_name: "aaa")
        @wp = create(:wiki_page, title: "aaa", body: "blah [[foo|blah]] [[FOO]] [[does not exist]] blah")
        @query = RelatedTagQuery.new(query: "xyz")
      end

      should "take wiki tags from the consequent's wiki" do
        assert_equal(%w[foo], @query.wiki_page_tags.pluck(:name))
      end

      should "take related tags from the consequent tag" do
        assert_equal(%w[aaa bbb ccc], @query.related_tags.map(&:name))
      end
    end

    context "for a pattern search" do
      setup do
        @query = RelatedTagQuery.new(query: "a*")
      end

      should "work" do
        assert_equal(%w[aaa bbb ccc], @query.related_tags.map(&:name))
      end
    end

    context "for a tag with a wiki page" do
      setup do
        @wiki_page = create(:wiki_page, title: "aaa", body: "[[bbb]] [[ccc]]")
        @query = RelatedTagQuery.new(query: "aaa")
      end

      should "find any tags embedded in the wiki page" do
        assert_equal(["bbb", "ccc"], @query.wiki_page_tags.pluck(:name))
      end

      should "return the tags in the same order as given by the wiki" do
        create(:wiki_page, title: "wiki", body: "[[ccc]] [[bbb]] [[ccc]] [[bbb]] [[aaa]]")

        query = RelatedTagQuery.new(query: "wiki")
        assert_equal(%w[ccc bbb aaa], query.wiki_page_tags.pluck(:name))
      end

      should "return aliased tags" do
        create(:tag, name: "cat", post_count: 42)
        create(:tag_alias, antecedent_name: "kitten", consequent_name: "cat", status: "active")
        create(:wiki_page, title: "wiki", body: "[[kitten]]")

        query = RelatedTagQuery.new(query: "wiki")
        assert_equal(%w[cat], query.wiki_page_tags.pluck(:name))
      end
    end
  end

  context "a related tag query with a category constraint" do
    setup do
      create(:post, tag_string: "aaa bbb")
      create(:post, tag_string: "aaa art:ccc")
      create(:post, tag_string: "aaa copy:ddd")
      @query = RelatedTagQuery.new(query: "aaa", categories: ["artist"])
    end

    should "find the related tags" do
      assert_equal(["ccc"], @query.related_tags.map(&:name))
    end
  end

  context "the search_sample_size param" do
    should "default to 5000" do
      assert_equal(5000, RelatedTagQuery.new(query: "aaa").search_sample_size)
    end

    should "be capped at 10,000 for anonymous users and members" do
      assert_equal(10_000, RelatedTagQuery.new(query: "aaa", search_sample_size: 100_000).search_sample_size)
      assert_equal(10_000, RelatedTagQuery.new(query: "aaa", search_sample_size: 100_000, user: create(:member_user)).search_sample_size)
    end

    should "be capped at 100,000 for Builder users and above" do
      assert_equal(100_000, RelatedTagQuery.new(query: "aaa", search_sample_size: 1_000_000, user: create(:builder_user)).search_sample_size)
    end
  end

  context "the tag limit" do
    should "raise an error if the query has more tags than the user is allowed to search for" do
      assert_raises(PostQuery::TagLimitError) { RelatedTagQuery.new(query: "aaa bbb ccc", user: create(:user)) }
    end

    should "allow queries within the user's tag limit" do
      assert_nothing_raised { RelatedTagQuery.new(query: "aaa bbb", user: create(:user)) }
      assert_nothing_raised { RelatedTagQuery.new(query: "aaa bbb ccc", user: create(:platinum_user)) }
    end
  end
end
