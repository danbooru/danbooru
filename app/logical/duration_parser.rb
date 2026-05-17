# frozen_string_literal: true

require "abbrev"

# Parses a duration string like "1min", "1m30s", "1:30", or "1:30.456" into an ActiveSupport::Duration.
module DurationParser
  # @return [Hash<String, Integer>] Units ordered from smallest (1) to largest.
  UNITS = { "seconds" => 1, "minutes" => 2, "hours" => 3, "days" => 4, "weeks" => 5, "months" => 6, "years" => 7 }

  # @return [Hash<String, String>] A mapping of unit abbreviations to their full names. Units can be abbreviated as
  #   "s", "sec", "m", "min", "h", "hr", "d", "w", "wk", "mo", "y", or "yr".
  ABBREVIATIONS = Abbrev.abbrev(UNITS.keys).merge("m" => "minutes", "hr" => "hours", "wk" => "weeks", "yr" => "years")

  # Parse a string as either a duration ("1min", "1m30s") or a timecode ("1:30", "1:30.456").
  #
  # @param string [String] The duration string.
  # @return [ActiveSupport::Duration] The parsed duration.
  # @raise [ArgumentError] If the string is not a valid duration.
  def self.parse(string)
    if string.include?(":")
      parse_timecode(string)
    else
      parse_duration(string)
    end
  end

  # Parse a duration string like "1m", "1m30s", or "1h 2min 30s" into a duration.
  #
  # @param string [String] The duration string.
  # @return [ActiveSupport::Duration] The parsed duration.
  # @raise [ArgumentError] If the string is not a valid duration.
  def self.parse_duration(string)
    parser = StringParser.new(string, state: UNITS.values.max + 1)

    # part = <float><optional space><unit>
    parts = parser.one_or_more do
      number = parser.expect(/((?:\d*\.)?\d+)/)
      parser.skip(/[[:space:]]*/)
      unit = parser.accept(/[a-z]+/i) || "seconds"
      parser.skip(/[[:space:]]*/)

      full_unit = ABBREVIATIONS[unit.downcase]
      parser.error("unknown unit '#{unit}' in '#{string}'") if full_unit.nil?

      weight = UNITS[full_unit]
      parser.error("units must go in descending order in '#{string}'") unless weight < parser.state
      parser.state = weight

      case full_unit
      in "seconds" then number.to_f.seconds
      in "minutes" then number.to_f.minutes
      in "hours"   then number.to_f.hours
      in "days"    then number.to_f.days
      in "weeks"   then number.to_f.weeks
      in "months"  then number.to_f * (365.25.days / 12)
      in "years"   then number.to_f * 365.25.days
      end
    end

    parser.error("unknown unit '#{parser.rest}' in '#{string}'") unless parser.eos?

    parts.sum
  rescue StringParser::Error => e
    raise ArgumentError, e.message
  end

  # Parse a timecode string like "30", "1:30", or "1:30.456" into a duration. The format is HH:MM:SS[.mmm], MM:SS[.mmm], or SS[.mmm].
  #
  # @param string [String] The timecode string.
  # @return [ActiveSupport::Duration] The parsed duration.
  # @raise [ArgumentError] If the string is not a valid timecode.
  def self.parse_timecode(string)
    case string
    # HH:MM:SS[.mmm] - 1:00:00, 10:02:03.456
    in /\A(\d{1,2}):(\d{2}):(\d{2}(?:\.\d+)?)\z/
      raise ArgumentError, "'#{string}' is not a valid timecode" if $2.to_i > 59 || $3.to_f >= 60
      $1.to_i.hours + $2.to_i.minutes + $3.to_f.seconds

    # MM:SS[.mmm] - 1:02, 01:02, 1:02.345
    in /\A(\d{1,2}):(\d{2}(?:\.\d+)?)\z/x
      raise ArgumentError, "'#{string}' is not a valid timecode" if $2.to_f >= 60
      $1.to_i.minutes + $2.to_f.seconds

    # [SS][.mmm] - 1, 1., 1.5, .5, 01.01
    in /\A((?:\d*\.)?\d+)\z/ if string.present?
      $1.to_f.seconds

    else
      raise ArgumentError, "'#{string}' is not a valid timecode"
    end
  end
end
