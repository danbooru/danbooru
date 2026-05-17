# frozen_string_literal: true

require "test_helper"

class RangeParserTest < ActiveSupport::TestCase
  context "RangeParser.parse with type :duration" do
    should "parse instants with 5% tolerance" do
      assert_equal([:between, (57.0..63.0)], RangeParser.parse("1min", :duration))
      assert_equal([:between, (85.5..94.5)], RangeParser.parse("90", :duration))
      assert_equal([:between, (85.5..94.5)], RangeParser.parse("1:30", :duration))
      assert_equal([:between, ((3765.0 * 0.95)..(3765.0 * 1.05))], RangeParser.parse("01:02:45", :duration))
      assert_equal([:between, ((15.123 * 0.95)..(15.123 * 1.05))], RangeParser.parse("0:15.123", :duration))
    end

    should "parse ranges without tolerance" do
      assert_equal([:gt, 90.0], RangeParser.parse(">90", :duration))
      assert_equal([:gt, 90.0], RangeParser.parse(">90s", :duration))
      assert_equal([:gt, 90.0], RangeParser.parse(">1m30s", :duration))
      assert_equal([:gt, 90.0], RangeParser.parse(">1:30", :duration))
      assert_equal([:gteq, 90.0], RangeParser.parse(">=1:30", :duration))
      assert_equal([:lt, 90.0], RangeParser.parse("<1:30", :duration))
      assert_equal([:lteq, 90.0], RangeParser.parse("<=1:30", :duration))
      assert_equal([:between, (30.0..90.0)], RangeParser.parse("0:30..1:30", :duration))
      assert_equal([:between, (30.0..90.0)], RangeParser.parse("30s..1m30s", :duration))
    end

    should "raise ParseError on invalid duration" do
      assert_raises(RangeParser::ParseError) { RangeParser.parse("abc", :duration) }
    end
  end

  context "RangeParser.parse with type :age" do
    should "not parse timecodes for :age type" do
      assert_raises(RangeParser::ParseError) { RangeParser.parse("1:30", :age) }
    end
  end

  context "RangeParser.parse with type :interval" do
    should "not parse timecodes for :interval type" do
      assert_raises(RangeParser::ParseError) { RangeParser.parse("1:30", :interval) }
    end
  end
end
