require 'test_helper'

class SearchableTest < ActiveSupport::TestCase
  def assert_search_equals(results, **params)
    assert_equal(Array(results).map(&:id), subject.search(**params).ids)
  end

  context "#search method" do
    subject { Post }

    setup do
      @p1 = create(:post, source: "a1", score: 1, is_deleted: true, uploader_ip_addr: "10.0.0.1")
      @p2 = create(:post, source: "b2", score: 2, is_deleted: false)
      @p3 = create(:post, source: "c3", score: 3, is_deleted: false)
    end

    context "for a numeric attribute" do
      should "support basic operators" do
        assert_search_equals(@p1, score_eq: 1)
        assert_search_equals(@p3, score_gt: 2)
        assert_search_equals(@p1, score_lt: 2)
        assert_search_equals([@p3, @p1], score_not_eq: 2)
        assert_search_equals([@p3, @p2], score_gteq: 2)
        assert_search_equals([@p2, @p1], score_lteq: 2)
      end

      should "support embedded expressions" do
        assert_search_equals(@p1, score: "1")
        assert_search_equals(@p3, score: ">2")
        assert_search_equals(@p1, score: "<2")
        assert_search_equals([@p3, @p2], score: ">=2")
        assert_search_equals([@p2, @p1], score: "<=2")
        assert_search_equals([@p3, @p2], score: "3,2")
        assert_search_equals([@p2, @p1], score: "1...3")
        assert_search_equals([@p2, @p1], score: "3...1")
        assert_search_equals([@p3, @p2, @p1], score: "1..3")
        assert_search_equals([@p3, @p2, @p1], score: "3..1")
      end
    end

    context "for a string attribute" do
      should "support various operators" do
        assert_search_equals(@p1, source: "a1")
        assert_search_equals(@p1, source_eq: "a1")
        assert_search_equals(@p1, source_like: "a*")
        assert_search_equals(@p1, source_ilike: "A*")
        assert_search_equals(@p1, source_regex: "^a.*")

        assert_search_equals(@p1, source_array: ["a1", "blah"])
        assert_search_equals(@p1, source_comma: "a1,blah")
        assert_search_equals(@p1, source_space: "a1 blah")
        assert_search_equals(@p1, source_lower_array: ["a1", "BLAH"])
        assert_search_equals(@p1, source_lower_comma: "a1,BLAH")
        assert_search_equals(@p1, source_lower_space: "a1 BLAH")

        assert_search_equals([@p3, @p2], source_not_eq: "a1")
        assert_search_equals([@p3, @p2], source_not_like: "a*")
        assert_search_equals([@p3, @p2], source_not_ilike: "A*")
        assert_search_equals([@p3, @p2], source_not_regex: "^a.*")
      end
    end

    context "for a boolean attribute" do
      should "work" do
        assert_search_equals(@p1, is_deleted: "true")
        assert_search_equals(@p1, is_deleted: "yes")
        assert_search_equals(@p1, is_deleted: "on")
        assert_search_equals(@p1, is_deleted: "1")

        assert_search_equals([@p3, @p2], is_deleted: "false")
        assert_search_equals([@p3, @p2], is_deleted: "no")
        assert_search_equals([@p3, @p2], is_deleted: "off")
        assert_search_equals([@p3, @p2], is_deleted: "0")
      end
    end

    context "for an inet attribute" do
      should "work" do
        assert_search_equals(@p1, uploader_ip_addr: "10.0.0.1")
        assert_search_equals(@p1, uploader_ip_addr: "10.0.0.1/24")
        assert_search_equals(@p1, uploader_ip_addr: "10.0.0.1,1.1.1.1")
        assert_search_equals(@p1, uploader_ip_addr: "10.0.0.1 1.1.1.1")
      end
    end

    context "for an enum attribute" do
      subject { PostFlag }

      should "work" do
        @pf = create(:post_flag, status: :pending)

        assert_search_equals(@pf, status: "pending")
        assert_search_equals(@pf, status: "pending,blah")
        assert_search_equals(@pf, status: "pending blah")
        assert_search_equals(@pf, status_id: 0)
      end
    end

    context "for an array attribute" do
      subject { WikiPage }

      should "work" do
        @wp = create(:wiki_page, other_names: ["a1", "b2"])

        assert_search_equals(@wp, other_names_include_any: "a1")
        assert_search_equals(@wp, other_names_include_any: "a1 blah")

        assert_search_equals(@wp, other_names_include_all: "a1")
        assert_search_equals(@wp, other_names_include_all: "a1 b2")

        assert_search_equals(@wp, other_names_include_any_array: ["a1", "blah"])
        assert_search_equals(@wp, other_names_include_all_array: ["a1", "b2"])

        assert_search_equals(@wp, other_names_include_any_lower: "A1 BLAH")
        assert_search_equals(@wp, other_names_include_all_lower: "A1 B2")

        assert_search_equals(@wp, other_names_include_any_lower_array: ["A1", "BLAH"])
        assert_search_equals(@wp, other_names_include_all_lower_array: ["A1", "B2"])

        assert_search_equals(@wp, other_name_count: 2)
      end
    end
  end
end
