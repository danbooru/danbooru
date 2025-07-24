# frozen_string_literal: true

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

class PostQuery
  class Parser
    extend Memoist

    attr_reader :parser, :metatags, :metatag_regex
    delegate :error, :rest, :eos?, :accept, :expect, :rewind, :zero_or_more, :one_or_more, :one_of, to: :parser

    # @param input [String] The search string to parse.
    # @param metatags [Array<String>] The list of metatags supported by the query.
    def initialize(input, metatags: [])
      @parser = StringParser.new(input, state: 0) # 0 is the initial number of unclosed parens.
      @metatags = metatags
      @metatag_regex = /(#{metatags.join("|")}):/i
    end

    # Parse a search and return the AST.
    #
    # @param string [String] The search string to parse.
    # @returns [PostQuery::AST] The AST of the parsed search.
    def self.parse(string, **options)
      new(string, **options).parse
    end

    concerning :ParserMethods do
      # Parse the search and return the AST, or return a search that matches nothing if the parse failed.
      #
      # @return [PostQuery::AST] The AST of the parsed search.
      def parse(**options)
        parse!(**options)
      rescue StringParser::Error
        AST.none
      end

      # Parse the search and return the AST, or raise an error if the parse failed.
      #
      # @return [PostQuery::AST] The AST of the parsed search.
      def parse!
        ast = root
        error("Unexpected EOS (rest: '#{rest}')") unless eos?
        error("Unclosed parentheses (#{unclosed_parens})") unless unclosed_parens == 0
        ast
      end

      private

      # root = or_clause [root]
      def root
        a = zero_or_more { or_clause }
        space

        if a.empty?
          AST.all
        elsif a.size == 1
          a.first
        else
          AST.new(:and, a)
        end
      end

      # or_clause = and_clause "or" or_clause | and_clause
      def or_clause
        a = and_clause

        space
        if accept(/or[[:space:]]+/i)
          b = or_clause
          AST.new(:or, [a, b])
        else
          a
        end
      end

      # and_clause = factor_list "and" and_clause | factor_list
      def and_clause
        a = factor_list

        space
        if accept(/and[[:space:]]+/i)
          b = and_clause
          AST.new(:and, [a, b])
        else
          a
        end
      end

      # factor_list = factor [factor_list]
      def factor_list
        a = one_or_more { factor }
        AST.new(:and, a)
      end

      # factor = "-" expr | "~" expr | expr
      def factor
        space

        if accept("-")
          AST.not(expr)
        elsif accept("~")
          AST.opt(expr)
        else
          expr
        end
      end

      # expr = "(" or_clause ")" | term
      def expr
        space

        if accept("(")
          self.unclosed_parens += 1
          a = or_clause
          expect(")")
          self.unclosed_parens -= 1
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
        name = expect(metatag_regex).delete_suffix(":")
        quoted, value = quoted_string

        AST.metatag(name, value, quoted)
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
          a = string(/(\\[[:space:]]|[^[:space:]])*/).gsub(/\\[[:space:]]/, " ") # handle backslash escaped spaces
          [false, a]
        end
      end

      # A wildcard is a string that contains a '*' character and that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
      def wildcard
        t = string(/(?=[^[:space:]]*\*)[^[:space:]\)~-][^[:space:]]*/, skip_balanced_parens: true)
        error("Invalid tag name: #{t}") if t.match?(/\A#{metatag_regex}/)
        space
        AST.wildcard(t)
      end

      # A tag is a string that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
      def tag
        t = string(/[^[:space:]\)~-][^[:space:]]*/, skip_balanced_parens: true)
        error("Invalid tag name: #{t}") if t.downcase.in?(%w[and or]) || t.include?("*") || t.match?(/\A#{metatag_regex}/)
        space
        AST.tag(t)
      end

      def string(pattern, skip_balanced_parens: false)
        str = expect(pattern)

        # XXX: Now put back any trailing right parens we mistakenly consumed.
        n = unclosed_parens
        while n > 0 && str.ends_with?(")")
          break if skip_balanced_parens && (str.has_balanced_parens? || str.in?(Tag::PERMITTED_UNBALANCED_TAGS))
          str.chop!
          rewind
          n -= 1
        end

        str
      end

      def space
        expect(/[[:space:]]*/)
      end
    end

    # The current number of '(' characters without a matching ')'. Used for
    # determining whether a trailing ')' is part of a tag or not.
    private def unclosed_parens
      parser.state
    end

    private def unclosed_parens=(n)
      parser.state = n
    end

    memoize :parse, :parse!
  end
end
