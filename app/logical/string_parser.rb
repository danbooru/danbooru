# frozen_string_literal: true

require "strscan"

# A StringParser is a wrapper around StringScanner that adds extra
# helper methods for writing parser-combinator style parsers.
#
# @see StringScanner
# @see https://hmac.dev/posts/2019-05-19-ruby-parser-combinators.html
class StringParser
  class Error < StandardError; end

  attr_reader :input
  attr_accessor :state
  private attr_reader :scanner

  delegate :rest, :eos?, to: :scanner

  # @param input [String] The string to parse.
  # @param state [Object] An arbitrary piece of user-defined state. Will be
  #   rolled back when the parser backtracks or is reset.
  def initialize(input, state: nil)
    @input = input.to_s.clone.freeze
    @state = state
    @scanner = StringScanner.new(@input)
  end

  # Try to match `pattern`, returning the string if it matched or nil if it didn't.
  #
  # @param pattern [Regexp, String] The pattern to match.
  # @return [String, nil] The matched string, or nil
  def accept(pattern)
    scanner.scan(pattern)
  end

  # Try to match `pattern`, returning the string if it matched or raising an Error if it didn't.
  #
  # @param pattern [Regexp, String] The pattern to match.
  # @return [String] The matched string
  # @raise [Error] If the pattern didn't match
  def expect(pattern)
    str = scanner.scan(pattern)
    error("Expected '#{pattern}'; got '#{str}'") if str.nil?
    str
  end

  # Move the scan pointer back N characters (default: 1)
  #
  # @param n [Integer] The number of characters to move back (default: 1).
  def rewind(n = 1)
    scanner.pos -= n
  end

  # Raise a parse error.
  #
  # @param message [String] The parse error message.
  # @raise [Error]
  def error(message)
    raise Error, message
  end

  # Try to parse the given block, backtracking to the previous state if the parse failed.
  def backtrack(&block)
    saved_pos = scanner.pos
    saved_state = state.deep_dup
    error("Unexpected EOS") if scanner.eos?
    yield
  rescue Error
    scanner.pos = saved_pos
    self.state = saved_state
    raise
  end

  # Parse the block zero or more times, returning an array of parse results.
  def zero_or_more(&block)
    matches = []
    loop do
      matches << backtrack { yield }
    end
  rescue Error
    matches
  end

  # Parse the block one or more times, returning an array of parse results.
  def one_or_more(&block)
    first = yield
    rest = zero_or_more(&block)
    [first, *rest]
  end

  # Given a list of parsers, try each in sequence and return the first one that succeeds.
  def one_of(parsers)
    parsers.each do |parser|
      return backtrack { parser.call }
    rescue Error
      next
    end

    error("expected one of: #{parsers}")
  end
end
