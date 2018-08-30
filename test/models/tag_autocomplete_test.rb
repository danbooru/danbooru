require 'test_helper'

class TagAutocompleteTest < ActiveSupport::TestCase
  subject { TagAutocomplete }

  context "#search" do
    should "be case insensitive" do
      create(:tag, name: "abcdef", post_count: 1)
      assert_equal(["abcdef"], subject.search("A").map(&:name))
    end
  end

  context "#search_exact" do
    setup do
      @tags = [
        create(:tag, name: "abcdef", post_count: 1),
        create(:tag, name: "abczzz", post_count: 2),
        create(:tag, name: "abcyyy", post_count: 0),
        create(:tag, name: "bbbbbb")
      ]
    end

    should "find the tags" do
      expected = [
        @tags[1],
        @tags[0]
      ].map(&:name)
      assert_equal(expected, subject.search_exact("abc", 3).map(&:name))
    end
  end

  context "#search_fuzzy" do
    setup do
      @tags = [
        create(:tag, name: "abcdef", post_count: 1),
        create(:tag, name: "abcdzz", post_count: 2),

        # one char mismatch
        create(:tag, name: "abcezz", post_count: 2),

        # too long
        create(:tag, name: "abcdefghijk", post_count: 2),

        # wrong prefix
        create(:tag, name: "bbcdef", post_count: 2),

        # zero post count
        create(:tag, name: "abcdyy", post_count: 0),

        # completely different
        create(:tag, name: "bbbbbb")
      ]
    end

    should "find the tags" do
      expected = [
        @tags[1],
        @tags[2],
        @tags[0]
      ].map(&:name)
      assert_equal(expected, subject.search_fuzzy("abcd", 3).map(&:name))
    end
  end

  context "#search_prefix" do
    setup do
      @tags = [
        create(:tag, name: "abcdef", post_count: 1),
        create(:tag, name: "alpha_beta_cat", post_count: 2),
        create(:tag, name: "alpha_beta_dat", post_count: 0),
        create(:tag, name: "alpha_beta_(cane)", post_count: 2),
        create(:tag, name: "alpha_beta/cane", post_count: 2)
      ]
    end

    should "find the tags" do
      expected = [
        @tags[1],
        @tags[3],
        @tags[4]
      ].map(&:name)
      assert_equal(expected, subject.search_prefix("abc", 3).map(&:name))
    end
  end

  context "#search_aliases" do
    setup do
      @user = create(:user)
      @tags = [
        create(:tag, name: "/abc", post_count: 0),
        create(:tag, name: "abcdef", post_count: 1),
        create(:tag, name: "zzzzzz", post_count: 1),
      ]
      as_user do
        @aliases = [
          create(:tag_alias, antecedent_name: "/abc", consequent_name: "abcdef", status: "active", post_count: 1)
        ]
      end
    end

    should "find the tags" do
      results = subject.search_aliases("/abc", 3)
      assert_equal(1, results.size)
      assert_equal("abcdef", results[0].name)
      assert_equal("/abc", results[0].antecedent_name)
    end
  end
end
