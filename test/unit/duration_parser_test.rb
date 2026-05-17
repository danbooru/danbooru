# frozen_string_literal: true

require "test_helper"

class DurationParserTest < ActiveSupport::TestCase
  context "DurationParser.parse" do
    should "parse plain numbers as seconds" do
      assert_equal(1.second, DurationParser.parse("1"))
      assert_equal(1.5.seconds, DurationParser.parse("1.5"))
      assert_equal(0.5.seconds, DurationParser.parse(".5"))
    end

    should "parse timecodes or durations" do
      assert_equal(90.seconds, DurationParser.parse("1m30s"))
      assert_equal(3765.seconds, DurationParser.parse("01:02:45"))
    end

    should "raise ArgumentError on invalid input" do
      assert_raises(ArgumentError) { DurationParser.parse("abc") }
      assert_raises(ArgumentError) { DurationParser.parse("") }
    end
  end

  context "DurationParser.parse_duration" do
    should "parse plain numbers as seconds" do
      assert_equal(1.second, DurationParser.parse_duration("1"))
      assert_equal(1.5.seconds, DurationParser.parse_duration("1.5"))
      assert_equal(0.5.seconds, DurationParser.parse_duration(".5"))
    end

    should "parse unit strings" do
      assert_equal(5.seconds, DurationParser.parse_duration("5s"))
      assert_equal(5.minutes, DurationParser.parse_duration("5m"))
      assert_equal(5.hours, DurationParser.parse_duration("5h"))
      assert_equal(5.days, DurationParser.parse_duration("5d"))
      assert_equal(5.weeks, DurationParser.parse_duration("5w"))
      assert_equal(365.25.days, DurationParser.parse_duration("12mo"))
      assert_equal(365.25.days, DurationParser.parse_duration("1y"))
    end

    should "parse compound duration strings" do
      assert_equal(90.seconds, DurationParser.parse_duration("1m30"))
      assert_equal(90.seconds, DurationParser.parse_duration("1m30s"))
      assert_equal(90.seconds, DurationParser.parse_duration("1m 30s"))
      assert_equal(1.hour + 30.minutes, DurationParser.parse_duration("1h30m"))
      assert_equal(1.hour + 30.minutes, DurationParser.parse_duration("1h 30m"))
      assert_equal(1.day + 2.hours + 3.minutes + 4.seconds, DurationParser.parse_duration("1d2h3m4s"))
      assert_equal(1.day + 2.hours + 3.minutes + 4.seconds, DurationParser.parse_duration("1d 2h 3m 4s"))
      assert_equal(1.day + 2.hours + 3.minutes + 4.seconds, DurationParser.parse_duration("1day 2hr 3min 4sec"))
      assert_equal(1.day + 2.hours + 3.minutes + 4.seconds, DurationParser.parse_duration("1 day 2 hr 3 min 4 sec"))
    end

    should "raise ArgumentError on invalid input" do
      assert_raises(ArgumentError) { DurationParser.parse_duration("5.") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("abc") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("1m abc") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("min 30s") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("3min 2min") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("30s 1min") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("1 30") }
      assert_raises(ArgumentError) { DurationParser.parse_duration("1:30") }
    end
  end

  context "DurationParser.parse_timecode" do
    should "parse plain numbers as seconds" do
      assert_equal(1.second, DurationParser.parse_timecode("1"))
      assert_equal(1.5.seconds, DurationParser.parse_timecode("1.5"))
      assert_equal(0.5.seconds, DurationParser.parse_timecode(".5"))
    end

    should "parse HH:MM:SS timecodes" do
      assert_equal(0.seconds, DurationParser.parse_timecode("0:00"))
      assert_equal(59.seconds, DurationParser.parse_timecode("0:59"))
      assert_equal(90.seconds, DurationParser.parse_timecode("1:30"))
      assert_equal(10.minutes, DurationParser.parse_timecode("10:00"))

      assert_equal(15.123.seconds, DurationParser.parse_timecode("0:15.123"))
      assert_equal(90.5.seconds, DurationParser.parse_timecode("1:30.5"))

      assert_equal(3723.seconds, DurationParser.parse_timecode("1:02:03"))
      assert_equal(3723.seconds, DurationParser.parse_timecode("01:02:03"))
      assert_equal(3723.456.seconds, DurationParser.parse_timecode("1:02:03.456"))
    end

    should "raise ArgumentError on invalid timecodes" do
      assert_raises(ArgumentError) { DurationParser.parse_timecode("1:3") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("01:3") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("01:02:3") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("01:2:30") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("001:30") }

      assert_raises(ArgumentError) { DurationParser.parse_timecode("0:60") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("1:60:00") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("1:00:60") }

      assert_raises(ArgumentError) { DurationParser.parse_timecode("abc") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("5.") }
      assert_raises(ArgumentError) { DurationParser.parse_timecode("") }
    end
  end
end
