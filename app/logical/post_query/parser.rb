# frozen_string_literal: true

require "strscan"

# A PostQuery::Parser parses a search string into a PostQuery::AST.
#
# @example
#
#   ast = PostQuery.new("1girl or 1boy").parse
#
# Grammar:
#
# root          = or_clause [root]
# or_clause     = and_clause "or" or_clause
#               | and_clause
# and_clause    = factor_list "and" and_clause
#               | factor_list
# factor_list   = factor [factor_list]
# factor        = "-" expr
#               | "~" expr
#               | expr
# expr          = "(" or_clause ")" | term
# term          = metatag | tag | wildcard
# metatag       = metatag_name ":" quoted_string
# metatag_name  = "user" | "fav" | "pool" | "order" | ...
# quoted_string = '"' /[^"]+/ '"'
#               | "'" /[^']+/ "'"
# tag           = /[^ *]+/
# wildcard      = /[^ ]+/
#
# Ref:
#
# * https://hmac.dev/posts/2019-05-19-ruby-parser-combinators.html

class PostQuery
  class Parser
    extend Memoist

    class Error < StandardError; end

    METATAG_NAME_REGEX = /(#{PostQueryBuilder::METATAGS.join("|")}):/i

    attr_reader :input
    private attr_reader :scanner, :unclosed_parens

    # @param input [String] The search string to parse.
    def initialize(input)
      @input = input.to_s.clone.freeze
      @scanner = StringScanner.new(@input)
      @unclosed_parens = 0
    end

    # Parse a search and return the AST.
    #
    # @param string [String] The search string to parse.
    # @returns [PostQuery::AST] The AST of the parsed search.
    def self.parse(string)
      new(string).parse
    end

    concerning :ParserMethods do
      # Parse the search and return the AST, or return a search that matches nothing if the parse failed.
      #
      # @return [PostQuery::AST] The AST of the parsed search.
      def parse
        parse!
      rescue Error
        node(:none)
      end

      # Parse the search and return the AST, or raise an error if the parse failed.
      #
      # @return [PostQuery::AST] The AST of the parsed search.
      def parse!
        ast = root
        raise Error, "Unexpected EOS (rest: '#{scanner.rest}')" unless scanner.eos?
        raise Error, "Unclosed parentheses (#{@unclosed_parens})" unless @unclosed_parens == 0
        ast
      end

      private

      # root = or_clause [root]
      def root
        a = zero_or_more { or_clause }
        space

        if a.empty?
          node(:all)
        elsif a.size == 1
          a.first
        else
          node(:and, *a)
        end
      end

      # or_clause = and_clause "or" or_clause | and_clause
      def or_clause
        a = and_clause

        space
        if accept(/or +/i)
          b = or_clause
          node(:or, a, b)
        else
          a
        end
      end

      # and_clause = factor_list "and" and_clause | factor_list
      def and_clause
        a = factor_list

        space
        if accept(/and +/i)
          b = and_clause
          node(:and, a, b)
        else
          a
        end
      end

      # factor_list = factor [factor_list]
      def factor_list
        a = one_or_more { factor }
        node(:and, *a)
      end

      # factor = "-" expr | "~" expr | expr
      def factor
        space

        if accept("-")
          node(:not, expr)
        elsif accept("~")
          node(:opt, expr)
        else
          expr
        end
      end

      # expr = "(" or_clause ")" | term
      def expr
        space

        if accept("(")
          @unclosed_parens += 1
          a = or_clause
          expect(")")
          @unclosed_parens -= 1
          a
        else
          term
        end
      end

      # term = metatag | tag | wildcard
      def term
        one_of [
          method(:tag),
          method(:metatag),
          method(:wildcard),
        ]
      end

      # metatag = metatag_name ":" quoted_string
      # metatag_name = "user" | "fav" | "pool" | "order" | ...
      def metatag
        name = expect(METATAG_NAME_REGEX)
        quoted, value = quoted_string

        name = name.delete_suffix(":").downcase
        name = name.singularize + "_count" if name.in?(PostQueryBuilder::COUNT_METATAG_SYNONYMS)

        if name == "order"
          attribute, direction, _tail = value.to_s.downcase.partition(/_(asc|desc)\z/i)
          if attribute.in?(PostQueryBuilder::COUNT_METATAG_SYNONYMS)
            value = attribute.singularize + "_count" + direction
          end
        end

        node(:metatag, name, value, quoted)
      end

      def quoted_string
        if accept('"')
          a = accept(/([^"\\]|\\")*/).gsub(/\\"/, '"') # handle backslash escaped quotes
          expect('"')
          [true, a]
        elsif accept("'")
          a = accept(/([^'\\]|\\')*/).gsub(/\\'/, "'") # handle backslash escaped quotes
          expect("'")
          [true, a]
        else
          [false, string(/[^ ]+/)]
        end
      end

      # A wildcard is a string that contains a '*' character and that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
      def wildcard
        t = string(/(?=[^ ]*\*)[^ \)~-][^ ]*/, skip_balanced_parens: true)
        raise Error if t.match?(/\A#{METATAG_NAME_REGEX}/)
        space
        node(:wildcard, t.downcase)
      end

      # A tag is a string that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
      def tag
        t = string(/[^ \)~-][^ ]*/, skip_balanced_parens: true)
        raise Error if t.downcase.in?(%w[and or]) || t.include?("*") || t.match?(/\A#{METATAG_NAME_REGEX}/)
        space
        node(:tag, t.downcase)
      end

      def string(pattern, skip_balanced_parens: false)
        str = expect(pattern)

        # XXX: Now put back any trailing right parens we mistakenly consumed.
        n = @unclosed_parens
        while n > 0 && str.ends_with?(")")
          break if skip_balanced_parens && (str.has_balanced_parens? || str.in?(Tag::PERMITTED_UNBALANCED_TAGS))
          str.chop!
          scanner.pos -= 1
          n -= 1
        end

        str
      end

      def space
        expect(/ */)
      end
    end

    concerning :HelperMethods do
      private

      # Try to match `pattern`, returning the string if it matched or nil if it didn't.
      #
      # @param pattern [Regexp, String] The pattern to match.
      # @return [String, nil] The matched string, or nil
      def accept(pattern)
        @scanner.scan(pattern)
      end

      # Try to match `pattern`, returning the string if it matched or raising an Error if it didn't.
      #
      # @param pattern [Regexp, String] The pattern to match.
      # @return [String] The matched string
      def expect(pattern)
        str = accept(pattern)
        raise Error, "Expected '#{pattern}'; got '#{str}'" if str.nil?
        str
      end

      # Try to parse the given block, backtracking to the original state if the parse failed.
      def backtrack(&block)
        saved_pos = @scanner.pos
        saved_unclosed_parens = @unclosed_parens
        raise Error if @scanner.eos?
        yield
      rescue Error
        @scanner.pos = saved_pos
        @unclosed_parens = saved_unclosed_parens
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

      # Given a list of parsers, return the first one that succeeds.
      def one_of(parsers)
        parsers.each do |parser|
          return backtrack { parser.call }
        rescue Error
          next
        end

        raise Error, "expected one of: #{parsers}"
      end

      # Build an AST node of the given type.
      def node(type, *args)
        AST.new(type, args)
      end
    end

    memoize :parse, :parse!
  end
end
