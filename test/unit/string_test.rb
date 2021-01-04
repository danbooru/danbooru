require 'test_helper'

class StringTest < ActiveSupport::TestCase
  context "String#to_escaped_for_sql_like" do
    should "work" do
      assert_equal('foo\%bar', 'foo%bar'.to_escaped_for_sql_like)
      assert_equal('foo\_bar', 'foo_bar'.to_escaped_for_sql_like)
      assert_equal('foo%bar', 'foo*bar'.to_escaped_for_sql_like)
      assert_equal('foo*bar', 'foo\*bar'.to_escaped_for_sql_like)
      assert_equal('foo\\\\%bar', 'foo\\\\*bar'.to_escaped_for_sql_like)
      assert_equal('foo\\\\bar', 'foo\bar'.to_escaped_for_sql_like)

      assert_equal('%\\\\%', '*\\\\*'.to_escaped_for_sql_like)
      assert_equal('%*%', '*\**'.to_escaped_for_sql_like)
    end
  end

  context "String#normalize_whitespace" do
    should "normalize unicode spaces" do
      assert_equal("foo bar", "foo bar".normalize_whitespace)
      assert_equal("foo bar", "foo\u00A0bar".normalize_whitespace)
      assert_equal("foo bar", "foo\u3000bar".normalize_whitespace)
    end

    should "strip zero width characters" do
      assert_equal("foobar", "foo\u180Ebar".normalize_whitespace)
      assert_equal("foobar", "foo\u200Bbar".normalize_whitespace)
      assert_equal("foobar", "foo\u200Cbar".normalize_whitespace)
      assert_equal("foobar", "foo\u200Dbar".normalize_whitespace)
      assert_equal("foobar", "foo\u2060bar".normalize_whitespace)
      assert_equal("foobar", "foo\uFEFFbar".normalize_whitespace)
    end

    should "normalize line endings" do
      assert_equal("foo\r\nbar", "foo\r\nbar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\nbar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\rbar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\vbar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\fbar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\u0085bar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\u2028bar".normalize_whitespace)
      assert_equal("foo\r\nbar", "foo\u2029bar".normalize_whitespace)
    end
  end
end
