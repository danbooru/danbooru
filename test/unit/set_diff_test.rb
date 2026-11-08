require "test_helper"

class SetDiffTest < ActiveSupport::TestCase
  context "SetDiff" do
    should "detect added, removed, changed, and unchanged strings" do
      diff = SetDiff.new(%w[https://a.com/foo https://b.com/bar https://z.com], %w[https://a.com/fo xyz https://z.com])

      assert_equal(["https://b.com/bar"], diff.added)
      assert_equal(["xyz"], diff.removed)
      assert_equal([["https://a.com/fo", "https://a.com/foo"]], diff.changed)
      assert_equal(["https://z.com"], diff.unchanged)
    end

    should "match each removal with its most similar addition" do
      diff = SetDiff.new(%w[abcdxx abcdef], %w[abcdeg])

      assert_equal([%w[abcdeg abcdef]], diff.changed)
      assert_equal(["abcdxx"], diff.added)
      assert_equal([], diff.removed)
    end

    should "not match the same addition to multiple removals" do
      diff = SetDiff.new(%w[abcdef], %w[abcdeg abcdeh])

      assert_equal([%w[abcdeg abcdef]], diff.changed)
      assert_equal([], diff.added)
      assert_equal(["abcdeh"], diff.removed)
    end

    should "skip fuzzy matching when the diff is too large" do
      DidYouMean::Levenshtein.expects(:distance).never
      added = 150.times.map { |i| "https://example.com/#{i}/#{"a" * 270}" }
      removed = 150.times.map { |i| "https://example.com/#{i}/#{"b" * 270}" }
      diff = SetDiff.new(added, removed)

      assert_equal(added, diff.added)
      assert_equal(removed, diff.removed)
      assert_equal([], diff.changed)
    end
  end
end
