# frozen_string_literal: true

require "strscan"

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
# tag           = /[^ *]+/
# wildcard      = /[^ ]+/

class PostQuery
  class Parser
    extend Memoist

    class Error < StandardError; end

    METATAG_NAME_REGEX = /(#{PostQueryBuilder::METATAGS.join("|")}):/i

    attr_reader :input, :scanner

    def initialize(input)
      @input = input.to_s.strip
      @scanner = StringScanner.new(@input)
      @unclosed_parens = 0
    end

    def self.parse(string)
      new(string).parse
    end

    def self.simplify(string)
      new(string).simplify
    end

    concerning :HelperMethods do
      def accept(pattern)
        @scanner.scan(pattern)
      end

      def expect(pattern)
        str = accept(pattern)
        raise Error, "Expected '#{pattern}'; got '#{str}'" if str.nil?
        str
      end

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

      def zero_or_more(&block)
        matches = []
        loop do
          matches << backtrack { yield }
        end
      rescue Error
        matches
      end

      def one_or_more(&block)
        first = yield
        rest = zero_or_more(&block)
        [first, *rest]
      end

      def node(type, *args)
        AST.new(type, args)
      end
    end

    concerning :ParserMethods do
      def parse
        parse!
      rescue Error
        node(:none)
      end

      def parse!
        ast = root
        raise Error, "unexpected EOS ('#{scanner.rest}')" unless scanner.eos?
        raise Error, "unclosed parens (#{@unclosed_parens})" unless @unclosed_parens == 0
        ast
      end

      def root
        a = zero_or_more { or_clause }

        if a.empty?
          node(:all)
        elsif a.size == 1
          a.first
        else
          node(:and, *a)
        end
      end

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

      def factor_list
        a = one_or_more { factor }
        node(:and, *a)
      end

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

      def term
        metatag || wildcard || tag
      end

      def metatag
        if accept(METATAG_NAME_REGEX)
          name = @scanner.matched.delete_suffix(":")
          value = quoted_string
          node(:metatag, name.downcase, value)
        end
      end

      def quoted_string
        if accept('"')
          a = accept(/([^"\\]|\\")*/).gsub(/\\"/, '"')
          expect('"')
          a
        else
          string(/[^ ]+/)
        end
      end

      def wildcard
        # A wildcard is a string that contains a '*' character and that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
        if t = accept(/(?=[^ ]*\*)[^ \)~-][^ ]*/)
          space
          node(:wildcard, t.downcase)
        end
      end

      def tag
        # A tag is a string that begins with a nonspace, non-')', non-'~', or non-'-' character, followed by nonspace characters.
        t = string(/[^ \)~-][^ ]*/)
        raise Error if t.downcase.in?(%w[and or])
        space
        node(:tag, t.downcase)
      end

      def string(pattern)
        str = expect(pattern)

        # XXX: Now put back any trailing right parens we mistakenly consumed.
        n = @unclosed_parens
        while n > 0 && str.ends_with?(")")
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

    memoize :parse
  end
end
