# frozen_string_literal: true

# Parse a simple inequality expression into an operator and value. Used for parsing
# metatag values (e.g. `score:>5`) and URL params (e.g. /comments?search[score]=>5).
#
# @example
#
#   RangeParser.parse("5")      => [:eq, 5]
#   RangeParser.parse(">5")     => [:gt, 5]
#   RangeParser.parse(">=5")    => [:gteq, 5]
#   RangeParser.parse("<5")     => [:lt, 5]
#   RangeParser.parse("<=5")    => [:lteq, 5]
#   RangeParser.parse("5..")    => [:lteq, 5]
#   RangeParser.parse("..5")    => [:gteq, 5]
#   RangeParser.parse("5..10")  => [:between, (5..10)]
#   RangeParser.parse("5...10") => [:between, (5...10)]
#   RangeParser.parse("5,6,7")  => [:in, [5, 6, 7]]
#   RangeParser.parse("5,7..9") => [:union, [[:eq, 5], [:between, (7..9)]]]
#   RangeParser.parse("any")    => [:not_eq, nil]
#   RangeParser.parse("none")   => [:eq, nil]
#
class RangeParser
  class ParseError < StandardError; end

  attr_reader :string, :type

  def self.parse(...)
    new(...).parse
  end

  # @param string [String] The expression to parse
  # @param type [Symbol] The type of the expression (:enum, :integer, :float, :md5, :date, :datetime, :age, :interval, :ratio, or :filesize)
  def initialize(string, type = :integer)
    @string = string.to_s
    @type = type
  end

  # Parse a string expression into an operator and value.
  # @return [(Symbol, Object)] The operator name and the value
  def parse
    range = case string
    in _ if type == :enum
      [:in, string.split(/[, ]+/).map { |x| parse_value(x) }]
    in /[, ]/ if string.match?(/<|>|\.\./) # >A,<B,C..D
      [:union, string.split(/[, ]+/).map { |x| RangeParser.parse(x, type) }]
    in /[, ]/ # A,B,C
      [:in, string.split(/[, ]+/).map { |x| parse_value(x) }]
    in /\A(.+?)\.\.\.(.+)/ # A...B
      lo, hi = [parse_value($1), parse_value($2)].sort
      [:between, (lo...hi)]
    in /\A(.+?)\.\.(.+)/ # A..B
      lo, hi = [parse_value($1), parse_value($2)].sort
      [:between, (lo..hi)]
    in /\A<=(.+)/ | /\A\.\.(.+)/ # <=A, ..A
      [:lteq, parse_value($1)]
    in /\A<(.+)/ # <A
      [:lt, parse_value($1)]
    in /\A>=(.+)/ | /\A(.+)\.\.\z/ # >=A, A..
      [:gteq, parse_value($1)]
    in /\A>(.+)/ # >A
      [:gt, parse_value($1)]
    in "any"
      [:not_eq, nil]
    in "none"
      [:eq, nil]
    in _ if type == :float
      value = parse_value(string)
      [:between, (value * 0.95..value * 1.05)] # add a 5% tolerance for float values
    in /[km]b?\z/i if type == :filesize
      value = parse_value(string)
      [:between, (value * 0.95..value * 1.05)] # add a 5% tolerance for filesize values
    in _ if type in :date | :age
      value = parse_value(string)
      [:between, (value.beginning_of_day..value.end_of_day)]
    else
      [:eq, parse_value(string)]
    end

    range = reverse_range(range) if type == :age
    range
  end

  def reverse_range(range)
    case range
    in [:lteq, value]
      [:gteq, value]
    in [:lt, value]
      [:gt, value]
    in [:gteq, value]
      [:lteq, value]
    in [:gt, value]
      [:lt, value]
    else
      range
    end
  end

  # Parse a simple string value into a Ruby type.
  #
  # @param string [String] the value to parse
  # @return [Object] the parsed value
  def parse_value(string)
    case type
    when :enum
      string.downcase

    when :integer
      Integer(string) # raises ArgumentError if string is invalid

    when :float
      Float(string) # raises ArgumentError if string is invalid

    when :md5
      raise ParseError, "#{string} is not a valid MD5" unless string.match?(/\A[0-9a-fA-F]{32}\z/)
      string.downcase

    when :date, :datetime
      date = Time.zone.parse(string)
      raise ParseError, "#{string} is not a valid date" if date.nil?
      date

    when :age
      DurationParser.parse(string).ago

    when :interval
      DurationParser.parse(string)

    when :ratio
      string = string.tr(":", "/") # "2:3" => "2/3"
      Rational(string).to_f.round(2) # raises ArgumentError or ZeroDivisionError if string is invalid

    when :filesize
      raise ParseError, "#{string} is not a valid filesize" unless string =~ /\A(\d+(?:\.\d*)?|\d*\.\d+)([kKmM]?)[bB]?\Z/

      size = Float($1)
      unit = $2

      conversion_factor = case unit
      when /m/i
        1024 * 1024
      when /k/i
        1024
      else
        1
      end

      (size * conversion_factor).to_i

    else
      raise NotImplementedError, "unrecognized type #{type} for #{string}"
    end

  rescue ArgumentError, ZeroDivisionError => e
    raise ParseError, e.message
  end
end
