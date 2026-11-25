require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  context "#search method" do
    subject { Post }

    setup do
      @p1 = create(:post, source: "a1", score: 1, is_deleted: true)
      @p2 = create(:post, source: "b2", score: 2, is_deleted: false)
      @p3 = create(:post, source: "c3", score: 3, is_deleted: false)
    end

    context "for a nonexistent attribute" do
      should "raise an error" do
        assert_raises(ArgumentError) do
          PostPolicy.any_instance.stubs(:searchable_attributes).returns([:answer])
          Post.search_attributes({ answer: 42 }, current_user: User.anonymous)
        end
      end
    end

    context "for an attribute not allowed by the policy" do
      should "ignore the attribute" do
        PostPolicy.any_instance.stubs(:searchable_attributes).returns([:id])

        assert_search_equals([@p3, @p2, @p1], score: 1, source: "a1")
      end
    end

    context "for an attribute with an unknown search mode" do
      should "raise an error" do
        PostPolicy.any_instance.stubs(:searchable_attributes).returns([{ source: :fuzzy }])

        assert_raises(ArgumentError) { Post.search({ source: "a1" }, User.anonymous) }
      end
    end

    context "for an attribute that only allows exact matches" do
      setup do
        PostPolicy.any_instance.stubs(:searchable_attributes).returns([{ source: :exact }, { score: :exact }])
      end

      should "allow exact matches" do
        assert_search_equals(@p1, source: "a1")
        assert_search_equals(@p1, source_eq: "a1")
        assert_search_equals([@p3, @p2], source_not_eq: "a1")
        assert_search_equals(@p1, source_array: ["a1", "blah"])
        assert_search_equals([@p2, @p1], source_comma: "a1,b2")
        assert_search_equals([@p2, @p1], source_space: "a1 b2")
        assert_search_equals(@p2, score: 2)
        assert_search_equals(@p2, score_eq: 2)
      end

      should "not allow partial matches" do
        assert_search_equals([], source: "a*")
        assert_search_equals([], score: ">0")

        assert_search_equals([@p3, @p2, @p1], source_like: "a*")
        assert_search_equals([@p3, @p2, @p1], source_ilike: "A*")
        assert_search_equals([@p3, @p2, @p1], source_regex: "^a")
        assert_search_equals([@p3, @p2, @p1], source_not_like: "a*")
        assert_search_equals([@p3, @p2, @p1], source_lower_comma: "A1")
        assert_search_equals([@p3, @p2, @p1], score_gt: 1)
        assert_search_equals([@p3, @p2, @p1], score_lt: 3)
      end
    end

    context "for an exact match attribute with a hash value" do
      should "not raise an error" do
        PostPolicy.any_instance.stubs(:searchable_attributes).returns([{ md5: :exact }])

        assert_search_equals([], md5: { a: @p1.md5 })
        assert_search_equals([], md5_eq: { a: @p1.md5 })
        assert_search_equals([@p3, @p2, @p1], md5_not_eq: { a: @p1.md5 })
        assert_search_equals([], md5_array: { a: @p1.md5 })
      end
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

        assert_search_equals([@p3, @p2], score_not: "1")
        assert_search_equals(@p3, score_not: "1..2")
        assert_search_equals(@p1, score_not: ">1")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@p2, score_eq: 2, score_gt: 1)
        assert_search_equals(@p2, score_gt: 1, score_lt: 3)
        assert_search_equals(@p2, score_eq: 2, score_not: "1,3")
      end

      context "for a nullable numeric attribute" do
        subject { IpGeolocation }

        should "support the _present operator" do
          @g1 = create(:ip_geolocation, asn: nil)
          @g2 = create(:ip_geolocation, asn: 1234)

          assert_search_equals(@g2, asn_present: "true")
          assert_search_equals(@g1, asn_present: "false")
        end

        should "include null values for the _not operator" do
          @g1 = create(:ip_geolocation, asn: nil)
          @g2 = create(:ip_geolocation, asn: 1234)
          @g3 = create(:ip_geolocation, asn: 5678)

          assert_search_equals([@g3, @g1], asn_not: "1234")
          assert_search_equals(@g1, asn_not: "1000..9999")
        end
      end
    end

    context "for a string attribute" do
      should "support various operators" do
        assert_search_equals(@p1, source: "a1")
        assert_search_equals(@p1, source_eq: "a1")
        assert_search_equals(@p1, source_like: "a*")
        assert_search_equals(@p1, source_ilike: "A*")
        assert_search_equals(@p1, source_regex: "^a.*")

        assert_search_equals([], id: @p1.id, source_like: "A*")
        assert_search_equals([@p1], id: @p1.id, source_not_like: "A*")
        assert_search_equals([], id: @p1.id, source_regex: "^A.*")
        assert_search_equals([@p1], id: @p1.id, source_not_regex: "^A.*")

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

        assert_search_equals([], source_present: "false")
        assert_search_equals([@p3, @p2, @p1], source_present: "true")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals([], source: "a1", source_not_eq: "a1")
        assert_search_equals(@p1, source: "a1", source_not_eq: "b2")
      end

      context "for a like search" do
        subject { WikiPage }

        should "treat backslashes literally when the search doesn't contain a '*' wildcard" do
          @w1 = create(:wiki_page, title: "foo\\bar")
          @w2 = create(:wiki_page)

          assert_search_equals([@w1], title_like: "foo\\bar")
          assert_search_equals([@w1], title_ilike: "FOO\\BAR")

          assert_search_equals([@w2], title_not_like: "foo\\bar")
          assert_search_equals([@w2], title_not_ilike: "FOO\\BAR")

          assert_search_equals([], title_like: "foo\\\\bar")
        end
      end

      context "with a normalization" do
        subject { WikiPage }

        should "not normalize the attribute when searching using operators" do
          wp = create(:wiki_page, title: "foo_bar")

          assert_search_equals([], title_like: "FOO_BAR")
          assert_search_equals([], title_ilike: "foo bar")

          assert_search_equals([wp], title_not_like: "* *")
          assert_search_equals([wp], title_not_ilike: "* *")

          assert_search_equals([], title_regex: "FOO_BAR")
          assert_search_equals([wp], title_not_regex: ".* .*")
        end
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

    context "parse_search_params!" do
      should "parse each param as its type" do
        params = { min_level: "20", name: "foo", category: "1 4" }.with_indifferent_access

        assert_equal({ min_level: 20, name: "foo", category: [1, 4] }, Post.parse_search_params!(params, min_level: :integer, name: :string, category: [:integer]))
      end

      should "accept a list as an array" do
        params = { category: ["1", "4"] }.with_indifferent_access

        assert_equal({ category: [1, 4] }, Post.parse_search_params!(params, category: [:integer]))
      end

      should "accept integers from JSON request bodies" do
        params = { min_level: 20, name: 5, category: 1 }.with_indifferent_access

        assert_equal({ min_level: 20, name: "5", category: [1] }, Post.parse_search_params!(params, min_level: :integer, name: :string, category: [:integer]))
      end

      should "return nil for missing or blank params" do
        params = { name: "", category: [] }.with_indifferent_access

        assert_equal({ min_level: nil, name: nil, category: nil }, Post.parse_search_params!(params, min_level: :integer, name: :string, category: [:integer]))
      end

      should "only return the given params" do
        params = { min_level: "20", other: "foo" }.with_indifferent_access

        assert_equal({ min_level: 20 }, Post.parse_search_params!(params, min_level: :integer))
      end

      should "clamp integers to the 64-bit range" do
        params = { min_level: "99999999999999999999", max_level: "-99999999999999999999" }.with_indifferent_access

        assert_equal({ min_level: (2**63) - 1, max_level: -(2**63) }, Post.parse_search_params!(params, min_level: :integer, max_level: :integer))
      end

      should "raise an error for params of the wrong type" do
        error = assert_raises(Searchable::SearchError) { Post.parse_search_params!({ min_level: "abc" }.with_indifferent_access, min_level: :integer) }
        assert_equal("min_level must be an integer", error.message)

        error = assert_raises(Searchable::SearchError) { Post.parse_search_params!({ name: ["foo"] }.with_indifferent_access, name: :string) }
        assert_equal("name must be a string", error.message)

        error = assert_raises(Searchable::SearchError) { Post.parse_search_params!({ category: ["1", "x"] }.with_indifferent_access, category: [:integer]) }
        assert_equal("category must be a list of integers", error.message)

        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ min_level: ["20"] }.with_indifferent_access, min_level: :integer) }
        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ min_level: "1.5" }.with_indifferent_access, min_level: :integer) }
        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ min_level: true }.with_indifferent_access, min_level: :integer) }
        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ name: { a: 1 }}.with_indifferent_access, name: :string) }
        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ category: { a: 1 }}.with_indifferent_access, category: [:integer]) }
        assert_raises(Searchable::SearchError) { Post.parse_search_params!({ category: [["1"]] }.with_indifferent_access, category: [:integer]) }
      end
    end

    context "for search values with the wrong type" do
      should "raise a search error" do
        assert_raises(Searchable::SearchError) { Post.search({ is_deleted: "abc" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ is_deleted: ["1", "2"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ is_deleted: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_eq: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score_eq: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score_not: ["1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ created_at_eq: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Comment.search({ body_matches: ["a"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ForumTopic.search({ min_level: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ForumTopic.search({ min_level: ["a", "b"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ForumTopic.search({ min_level_not: ["a"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ ip_addr: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ ip_addr: ["1.1.1.1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ metadata: "abc" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ metadata: ["1", "2"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ForumPostVote.search({ forum_post: "abc" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ForumPostVote.search({ forum_post: ["1", "2"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ uploader: "abc" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { ModerationReport.search({ Comment: "abc" }, User.anonymous).load }
      end

      should "raise a search error for lists sent to operators that take a single value" do
        assert_raises(Searchable::SearchError) { Post.search({ source_like: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_ilike: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_not_like: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_not_ilike: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_regex: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_not_regex: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_comma: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_space: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_comma: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_space: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_present: ["true"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score: ["1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score_eq: ["1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score_gt: ["1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ score_present: ["true"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ created_at_eq: ["x"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { PostFlag.search({ status_id_eq: ["0"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_any: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ any_other_name_matches_regex: ["a1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_name_count: ["1"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ metadata_has_key: ["a"] }, User.anonymous).load }
      end

      should "raise a search error for nested lists and hashes" do
        assert_raises(Searchable::SearchError) { Post.search({ source_like: { "x" => "1" }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source: [["a1"]] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_array: [{ "x" => "1" }] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_array: [["a1"]] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_array: [nil] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_any_array: [["a1"]] }, User.anonymous).load }
      end

      should "accept numbers and booleans from JSON request bodies" do
        assert_search_equals(@p1, source_like: "a*")
        assert_search_equals([], source_like: 1)
        assert_search_equals(@p1, score: 1)
        assert_search_equals(@p1, score_eq: 1)
        assert_search_equals([@p2, @p1], score_lt: 3)
        assert_search_equals(@p1, is_deleted: true)
        assert_search_equals([@p3, @p2], is_deleted: false)
        assert_search_equals([@p2, @p1], source_array: ["a1", "b2"])
        assert_search_equals([@p2, @p1], source_lower_array: ["A1", "B2"])
        assert_search_equals(@p1, source_lower_array: "A1")
        assert_search_equals([@p3, @p2, @p1], source_present: true)
        assert_search_equals([@p3, @p2, @p1], score_present: true)
      end

      should "raise a search error for invalid integers in integer array searches" do
        assert_raises(Searchable::SearchError) { FavoriteGroup.search({ post_ids_include_any_array: ["x"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { FavoriteGroup.search({ post_ids_include_all_array: ["1", "x"] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { FavoriteGroup.search({ post_ids_include_any: "x" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { FavoriteGroup.search({ post_ids_include_all: "1 x" }, User.anonymous).load }
      end

      should "raise a search error for invalid durations" do
        assert_raises(Searchable::SearchError) { Ban.search({ duration_eq: "x" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Ban.search({ duration_gt: "1 fortnight" }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Ban.search({ duration_lteq: ["1d"] }, User.anonymous).load }
      end

      should "return nothing for numbers too large for the column" do
        assert_search_equals([], id: "99999999999999999999")
        assert_search_equals([], id: ">99999999999999999999")
        assert_search_equals([@p3, @p2, @p1], id: "<99999999999999999999")
        assert_search_equals([@p1], id: "#{@p1.id},99999999999999999999")
      end
    end

    context "for list params with too many items" do
      setup do
        @max = Searchable::MAX_SEARCH_LIST_ITEMS
        @words = (1..(@max + 1)).map { |i| "x#{i}" }
      end

      should "allow lists up to the limit" do
        assert_search_equals(@p1, source_array: ["a1", *@words.take(@max - 1)])
        assert_search_equals(@p1, source_comma: ["a1", *@words.take(@max - 1)].join(","))
        assert_search_equals(@p1, source: ["a1", *@words.take(@max - 1)])
      end

      should "raise an error for array params" do
        assert_raises(Searchable::SearchError) { Post.search({ source: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_eq: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_not_eq: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_array: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_array: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_array: [@words] }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ uploader: { name: @words }}, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_any_array: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_all_lower_array: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_match: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { TagImplication.search({ category: @words.map { "0" }}, User.anonymous).load }
      end

      should "raise an error for comma or space-separated params" do
        assert_raises(Searchable::SearchError) { Post.search({ source_comma: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_space: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_comma: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_lower_space: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_any: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_all: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_any_lower: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { WikiPage.search({ other_names_include_all_lower: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { PostFlag.search({ status: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { PostFlag.search({ status_not: @words.join(" ") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { UserEvent.search({ ip_addr: @words.map { "1.1.1.1" }.join(",") }, create(:admin_user)).load }
        assert_raises(Searchable::SearchError) { Tag.search({ name_normalize: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { BulkUpdateRequest.search({ status: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { TagImplication.search({ category: @words.map { "0" }.join(" ") }, User.anonymous).load }
      end

      should "raise an error for exact match attributes" do
        PostPolicy.any_instance.stubs(:searchable_attributes).returns([{ source: :exact }])

        assert_raises(Searchable::SearchError) { Post.search({ source_array: @words }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_comma: @words.join(",") }, User.anonymous).load }
        assert_raises(Searchable::SearchError) { Post.search({ source_space: @words.join(" ") }, User.anonymous).load }
      end
    end

    context "for an inet attribute" do
      subject { UserEvent }

      should "work" do
        @us1 = create(:user_event, ip_addr: "10.0.0.1")
        @us2 = create(:user_event, ip_addr: "11.0.0.1")

        assert_search_equals(@us1, ip_addr: "10.0.0.1")
        assert_search_equals(@us1, ip_addr: "10.0.0.1/24")
        assert_search_equals(@us1, ip_addr: "10.0.0.1,1.1.1.1")
        assert_search_equals(@us1, ip_addr: "10.0.0.1 1.1.1.1")

        assert_search_equals([@us2, @us1], ip_addr: "10.1.0.0/8,11.1.0.0/8")
        assert_search_equals([@us2, @us1], ip_addr: "10.1.0.0/8 11.1.0.0/8")

        assert_search_equals([], ip_addr: "10.0.0.x")
        assert_search_equals([], ip_addr: "10.0.0.x 11.0.0.y")
      end
    end

    context "for an enum attribute" do
      subject { PostFlag }

      should "work" do
        @pf1 = create(:post_flag, status: :pending)
        @pf2 = create(:post_flag, status: :rejected)

        assert_search_equals(@pf1, status: "pending")
        assert_search_equals(@pf1, status: "pending,blah")
        assert_search_equals(@pf1, status: "pending blah")

        assert_search_equals(@pf2, status_not: "pending")
        assert_search_equals([], status_not: "pending,rejected")

        assert_search_equals(@pf1, status_id: "0")
        assert_search_equals(@pf1, status_id_eq: "0")
        assert_search_equals([@pf2, @pf1], status_id: "0 2")
        assert_search_equals([@pf2, @pf1], status_id: "0,2")
        assert_search_equals([@pf2, @pf1], status_id: "0..2")
        assert_search_equals([@pf2], status_id: ">0")

        assert_search_equals(@pf2, status_id_not: "0")
        assert_search_equals(@pf2, status_id_not_eq: "0")
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@pf1, status: "pending", status_id: PostFlag.statuses[:pending])
        assert_search_equals([], status: "pending", status_id: PostFlag.statuses[:rejected])
        assert_search_equals(@pf1, status_id: PostFlag.statuses[:pending], status_id_not: PostFlag.statuses[:rejected])
      end
    end

    context "for an enum attribute with spaces in its values" do
      subject { ForumTopic }

      should "work" do
        @general = create(:forum_topic, category: "General")
        @bugs = create(:forum_topic, category: "Bugs & Features")

        assert_search_equals(@bugs, category: "Bugs & Features")
        assert_search_equals(@bugs, category: "bugs & features")
        assert_search_equals([@bugs, @general], category: "General,Bugs & Features")
        assert_search_equals(@general, category_not: "Bugs & Features")
      end
    end

    context "for an array attribute" do
      subject { WikiPage }

      should "work" do
        @wp1 = create(:wiki_page, other_names: ["a1", "b2"])
        @wp2 = create(:wiki_page, other_names: ["c3", "d4"])

        assert_search_equals(@wp1, other_names_include_any: "a1")
        assert_search_equals(@wp1, other_names_include_any: "a1 blah")

        assert_search_equals(@wp1, other_names_include_all: "a1")
        assert_search_equals(@wp1, other_names_include_all: "a1 b2")

        assert_search_equals(@wp1, other_names_include_any_array: ["a1", "blah"])
        assert_search_equals(@wp1, other_names_include_all_array: ["a1", "b2"])

        assert_search_equals(@wp1, other_names_include_any_lower: "A1 BLAH")
        assert_search_equals(@wp1, other_names_include_all_lower: "A1 B2")

        assert_search_equals(@wp1, other_names_include_any_lower_array: ["A1", "BLAH"])
        assert_search_equals(@wp1, other_names_include_all_lower_array: ["A1", "B2"])

        assert_search_equals(@wp1, any_other_name_matches_regex: "^a")
        assert_search_equals(@wp1, any_other_name_matches_regex: "[ab][12]")

        assert_search_equals([@wp2, @wp1], other_name_count: 2)
      end

      context "of integers" do
        subject { FavoriteGroup }

        should "work" do
          @p1, @p2, @p3 = create_list(:post, 3)
          @fg1 = create(:favorite_group, post_ids: [@p1.id, @p2.id])
          @fg2 = create(:favorite_group, post_ids: [@p3.id])

          assert_search_equals(@fg1, post_ids_include_any: "#{@p1.id} 0")
          assert_search_equals(@fg1, post_ids_include_all: "#{@p1.id} #{@p2.id}")
          assert_search_equals(@fg1, post_ids_include_any_array: [@p1.id.to_s, "0"])
          assert_search_equals(@fg1, post_ids_include_any_array: [@p1.id, 0])
          assert_search_equals(@fg1, post_ids_include_all_array: [@p1.id.to_s, @p2.id.to_s])
          assert_search_equals(@fg1, post_ids_include_any_lower: "#{@p1.id} 0")
          assert_search_equals(@fg1, post_ids_include_any_lower_array: [@p1.id, 0])
          assert_search_equals(@fg1, any_post_id_matches_regex: "^#{@p1.id}$")
          assert_search_equals([], post_ids_include_any_array: ["99999999999999999999"])
        end
      end

      should "support multiple operators on the same attribute" do
        assert_search_equals(@wp1, other_names_include_any: "a1", other_name_count: 2)
        assert_search_equals(@wp2, other_names_include_any: "c3", other_name_count: 2)
      end

      context "with a normalization" do
        should "not normalize the attribute when searching using operators" do
          create(:wiki_page, other_names: ["foo_bar"])

          assert_search_equals([], other_names_include_any: "foo bar")
          assert_search_equals([], other_names_include_all: "foo bar")
        end
      end
    end

    context "for a belongs_to association" do
      context "for a user association" do
        should "work" do
          assert_search_equals(@p1, uploader_id: @p1.uploader_id)
          assert_search_equals(@p1, uploader_name: @p1.uploader.name)

          assert_search_equals(@p1, uploader: { id: @p1.uploader_id })
          assert_search_equals(@p1, uploader: { name: @p1.uploader.name })

          assert_search_equals(@p1, uploader: { name: @p1.uploader.name }, uploader_id: @p1.uploader.id)
          assert_search_equals([], uploader: { name: @p1.uploader.name }, uploader_id: @p2.uploader.id)
        end
      end

      context "for a post association" do
        should "work" do
          @p1.update!(parent: @p2)

          assert_search_equals(@p1, parent_id: @p2.id)
          assert_search_equals(@p1, parent: { id: @p2.id })

          assert_search_equals(@p1, parent_tags_match: "id:#{@p2.id}")
          assert_search_equals([], parent_tags_match: "id:0")

          assert_search_equals(@p2, children_tags_match: "id:#{@p1.id}")
          assert_search_equals([], children_tags_match: "id:0")

          assert_search_equals(@p1, has_parent: true)
          assert_search_equals([@p3, @p2], has_parent: false)
        end
      end

      context "for a polymorphic association" do
        subject { ModerationReport }

        should "work" do
          as(create(:user)) do
            @mr1 = create(:moderation_report, model: create(:comment))
            @mr2 = create(:moderation_report, model: create(:forum_post))
            @mr3 = create(:moderation_report, model: create(:dmail))
          end

          assert_search_equals(@mr1, model_type: "Comment")
          assert_search_equals(@mr2, model_type: "ForumPost")
          assert_search_equals(@mr3, model_type: "Dmail")

          assert_search_equals(@mr1, model_type: "Comment", model_id: @mr1.model.id)
          assert_search_equals(@mr2, model_type: "ForumPost", model_id: @mr2.model.id)
          assert_search_equals(@mr3, model_type: "Dmail", model_id: @mr3.model.id)

          assert_search_equals([@mr2, @mr1], model_type_not_eq: "Dmail")
          assert_search_equals([], model_type: "Dmail", model_id_not_eq: @mr3.model_id)

          assert_search_equals(@mr1, Comment: { body: @mr1.model.body })
          assert_search_equals(@mr2, ForumPost: { body: @mr2.model.body })

          assert_search_equals([], Dmail: { body: @mr3.model.body }, current_user: User.anonymous)
          assert_search_equals(@mr3, Dmail: { body: @mr3.model.body }, current_user: @mr3.model.owner)
        end
      end
    end

    context "for a has_many association" do
      should "work" do
        as(@p1.uploader) { create(:comment, post: @p1) }

        assert_search_equals(@p1, has_comments: true)
        assert_search_equals([@p3, @p2], has_comments: false)

        assert_search_equals(@p1, comments: { id: @p1.comments.first.id })
        assert_search_equals(@p1, has_comments: true, comments: { id: @p1.comments.first.id })
      end

      context "with records the user can't see" do
        subject { User }

        should "not count deleted feedback for non-moderators" do
          user = create(:user)
          create(:user_feedback, user: user, is_deleted: true)

          assert_search_equals([], id: user.id, has_feedback: true)
          assert_search_equals(user, id: user.id, has_feedback: false)
          assert_search_equals(user, id: user.id, has_feedback: true, current_user: create(:moderator_user))
        end

        should "not count forum posts in mod-only topics for non-moderators" do
          user = create(:user)
          as(user) { create(:forum_post, creator: user, topic: create(:mod_up_forum_topic)) }

          assert_search_equals([], id: user.id, has_forum_posts: true)
          assert_search_equals(user, id: user.id, has_forum_posts: false)
          assert_search_equals(user, id: user.id, has_forum_posts: true, current_user: create(:moderator_user))
        end
      end
    end

    context "for a `has_many through: has_many` association" do
      subject { Upload }

      should "work" do
        @user = create(:user)
        @media_asset = create(:media_asset)
        @upload1 = create(:upload, uploader: @user, upload_media_assets: [build(:upload_media_asset, media_asset: @media_asset)])
        @upload2 = create(:upload, uploader: @user, upload_media_assets: [build(:upload_media_asset, media_asset: @media_asset)])
        @upload3 = create(:upload, uploader: @user, upload_media_assets: [build(:upload_media_asset)])

        assert_search_equals([@upload2, @upload1], media_assets: { md5: @media_asset.md5 }, current_user: @user)
      end
    end

    context "for a `has_one through: has_one` association" do
      subject { Post }

      should "work" do
        @post1 = create(:post_with_file)
        @post2 = create(:post)

        assert_search_equals([@post1], media_metadata: { id: @post1.media_metadata.id })
      end
    end

    context "for a `has_one through: belongs_to` association" do
      subject { AITag }

      should "work" do
        @post = create(:post_with_file)
        @ai_tag1 = create(:ai_tag, media_asset: @post.media_asset)
        @ai_tag2 = create(:ai_tag)

        assert_search_equals([@ai_tag1], post: { id: @post.id })
      end
    end

    context "for an interval attribute" do
      subject { Ban }

      should "work" do
        @ban1 = create(:ban, duration: 1.day)
        @ban2 = create(:ban, duration: 1.week)

        assert_search_equals(@ban1, duration: "1d")
        assert_search_equals(@ban1, duration_eq: "1d")
        assert_search_equals(@ban1, duration_eq: "1 day")
        assert_search_equals(@ban1, duration_eq: 1.day.to_i)
        assert_search_equals(@ban2, duration_not_eq: "1d")
        assert_search_equals(@ban2, duration_gt: "1d")
        assert_search_equals([@ban2, @ban1], duration_gteq: "1d")
        assert_search_equals(@ban1, duration_lt: "2d")
        assert_search_equals(@ban1, duration_lteq: "1d")
      end
    end

    context "timestamps" do
      should "work with relative times" do
        freeze_time do
          @post = create(:post, last_comment_bumped_at: 35.hours.ago)

          assert_search_equals([@post], last_comment_bumped_at: "1d..2d")
          assert_search_equals([@post], last_comment_bumped_at: "<1w")
          assert_search_equals([], last_comment_bumped_at: ">3d")
        end
      end

      should "work with absolute times" do
        @post = create(:post, last_comment_bumped_at: "2026-02-01T01:23:45Z")

        assert_search_equals([@post], last_comment_bumped_at: "..2026-02-03T00:00:00Z")
        assert_search_equals([@post], last_comment_bumped_at: "2026-02-01T00:00:00Z..2026-02-02T00:00:00Z")
        assert_search_equals([@post], last_comment_bumped_at: ">2026-02-01T00:00:00Z")
        assert_search_equals([], last_comment_bumped_at: "<2026-02-01T00:00:00Z")
      end
    end
  end

  context "the where_* helpers" do
    should "accept column names, Arel nodes, and Arel.sql fragments" do
      post = create(:post, score: 42, tag_string: "foo")

      assert_equal([post], Post.where_operator(:score, :eq, 42).to_a)
      assert_equal([post], Post.where_operator("score", :eq, 42).to_a)
      assert_equal([post], Post.where_operator(Post.arel_table[:score], :eq, 42).to_a)
      assert_equal([post], Post.where_operator(Arel.sql("posts.score"), :eq, 42).to_a)
      assert_equal([post], Post.where_array_includes_any(Arel.sql("string_to_array(posts.tag_string, ' ')"), ["foo"]).to_a)
    end

    should "accept column names for helpers that build SQL strings" do
      artist = create(:artist, other_names: ["Foo"])
      media_metadata = create(:media_metadata, metadata: { "File:FileType" => "PNG" })

      assert_equal([artist], Artist.where_array_count(:other_names, 1).to_a)
      assert_equal([artist], Artist.where_any_in_array_iequals(:other_names, ["foo"]).to_a)
      assert_equal([media_metadata], MediaMetadata.where_json_has_key(:metadata, "File:FileType").to_a)
      assert_equal([media_metadata], MediaMetadata.where_json_has_key(Arel.sql("media_metadata.metadata"), "File:FileType").to_a)
      assert_equal([media_metadata], MediaMetadata.where_json_has_key(MediaMetadata.arel_table[:metadata], "File:FileType").to_a)
      assert_equal([artist], Artist.where_array_count(Artist.arel_table.alias("a")[:other_names], 1).from("artists a").select("a.*").to_a)
    end

    should "raise an error for strings that aren't column names" do
      assert_raises(ArgumentError) { Post.where_operator("score = 0 OR 1=1 --", :eq, 42) }
      assert_raises(ArgumentError) { Post.where_operator(:nonexistent, :eq, 42) }
      assert_raises(ArgumentError) { Post.where_like("posts.source", "foo") }
      assert_raises(ArgumentError) { MediaMetadata.where_json_has_key("metadata; select 1", "foo") }
      assert_raises(ArgumentError) { MediaMetadata.where_json_has_key("media_metadata.metadata", "foo") }
      assert_raises(ArgumentError) { Artist.where_any_in_array_iequals("other_names) OR (1=1", ["foo"]) }
      assert_raises(ArgumentError) { Artist.where_array_count("cardinality(other_names)", 1) }
    end
  end

  context "every model's search" do
    should "quote values in the generated SQL" do
      Rails.application.eager_load!
      user = create(:superadmin_user)
      value = "zqx'zqx"
      suffixes = %w[
        _eq _not_eq _gt _gteq _lt _lteq _not _like _ilike _not_like _not_ilike _regex _not_regex _comma _space _lower_comma
        _lower_space _matches _has_key _include_any _include_all _include_any_lower _include_all_lower _count
      ]
      array_suffixes = %w[_array _lower_array _include_any_array _include_all_array _include_any_lower_array _include_all_lower_array]
      models = ApplicationRecord.descendants.select { |model| model.respond_to?(:search) && !model.abstract_class? }
      checked = 0

      models.each do |model|
        model.policy(user).search_modes.each_key do |attr|
          searches = [
            { attr => value },
            { attr => { name: value, id: value }},
            { "has_#{attr}" => value },
            { "any_#{attr.to_s.singularize}_matches_regex" => value },
            *suffixes.map { |suffix| { "#{attr}#{suffix}" => value } },
            *array_suffixes.map { |suffix| { "#{attr}#{suffix}" => [value] } },
          ]

          searches.each do |params|
            sql = begin
              model.search(params.with_indifferent_access, user).to_sql
            rescue Searchable::SearchError
              # Some malformed values raise errors before any SQL is built.
              next
            end

            assert_not_includes(sql, value, "#{model.name}.search(#{params.inspect}) didn't quote the value")
            checked += 1
          end
        end
      end

      assert_operator(checked, :>, 1000)
    end
  end
end
