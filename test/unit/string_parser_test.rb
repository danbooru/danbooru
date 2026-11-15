require "test_helper"

class StringParserTest < ActiveSupport::TestCase
  def count_exceptions(&block)
    count = 0
    TracePoint.new(:raise) { count += 1 }.enable(&block)
    count
  end

  context "StringParser" do
    should "raise an error when parsing fails outside of a backtracking block" do
      parser = StringParser.new("abc")

      assert_raises(StringParser::Error) { parser.expect("x") }
      assert_raises(StringParser::Error) { parser.one_or_more { parser.expect("x") } }
      assert_raises(StringParser::Error) { parser.one_of([-> { parser.expect("x") }, -> { parser.expect("y") }]) }
    end

    should "return the first parser that succeeds in one_of" do
      parser = StringParser.new("abc")

      assert_equal("abc", parser.one_of([-> { parser.expect("ab") && parser.expect("x") }, -> { parser.expect("abc") }]))
      assert(parser.eos?)
    end

    should "parse as many matches as possible in zero_or_more" do
      parser = StringParser.new("aaab")

      assert_equal(%w[a a a], parser.zero_or_more { parser.expect("a") })
      assert_equal([], parser.zero_or_more { parser.expect("a") })
      assert_equal("b", parser.rest)
    end

    should "restore the position and state after a failed parse" do
      parser = StringParser.new("aab", state: 0)

      matches = parser.zero_or_more do
        parser.state += 1
        parser.expect("a") + parser.expect("a")
      end

      assert_equal(["aa"], matches)
      assert_equal(1, parser.state)
      assert_equal("b", parser.rest)
    end

    should "not mix up failures from different parsers" do
      outer = StringParser.new("ab")
      inner = StringParser.new("x")

      result = outer.one_of([-> { outer.expect("a") && inner.one_of([-> { inner.expect("y") }, -> { inner.expect("x") }]) }])

      assert_equal("x", result)
      assert_equal("b", outer.rest)
    end

    should "not raise exceptions when backtracking" do
      parser = StringParser.new("a b c d")

      assert_equal(0, count_exceptions { parser.zero_or_more { parser.skip(/ */) && parser.one_of([-> { parser.expect("x") }, -> { parser.expect(/[a-z]/) }]) } })
      assert_equal(%w[a b c d], PostQuery::Parser.parse("(a or (b and -(~c ~d)))").tags.map(&:name))
      assert_equal(0, count_exceptions { PostQuery::Parser.parse("(a or (b and -(~c ~d))) order:score", metatags: PostQueryBuilder::METATAGS) })
    end
  end
end
