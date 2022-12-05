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

  context "String#invisible?" do
    should "work" do
      assert_equal(true, "".invisible?)
      assert_equal(true, " ".invisible?)
      assert_equal(true, "\v\t\f\r\n".invisible?)
      assert_equal(true, "\u00A0\u00AD\u034F\u061C\u115F\u1160\u17B4\u17B5\u180B\u180C\u180D\u180E".invisible?)
      assert_equal(true, "\u200B\u200C\u200D\u200E\u200F\u2028\u2029\u2060\u206F\u2800\u3000\u3164".invisible?)
      assert_equal(true, "\uFE00\uFE0F\uFEFF\uFFA0".invisible?)
      assert_equal(true, "\u{E0001}\u{E007F}".invisible?)

      assert_equal(false, "foo".invisible?)
      assert_equal(false, "\u0000".invisible?) # https://codepoints.net/U+0000 (NULL)
      assert_equal(false, "\u0001".invisible?) # https://codepoints.net/U+0001 (START OF HEADING)
      assert_equal(false, "\uE000".invisible?) # https://codepoints.net/U+E000 (PRIVATE USE CHARACTER)
      assert_equal(false, "\uFDD0".invisible?) # https://codepoints.net/U+FDD0 (NONCHARACTER)
      assert_equal(false, "\uFFF9".invisible?) # https://codepoints.net/U+FFF9 (INTERLINEAR ANNOTATION ANCHOR)
      assert_equal(false, "\uFFFF".invisible?) # https://codepoints.net/U+FFFF (NONCHARACTER)
      assert_equal(false, "\u{1D159}".invisible?) # https://codepoints.net/U+1D159 (MUSICAL SYMBOL NULL NOTEHEAD)
      assert_equal(false, "\u{1D455}".invisible?) # https://codepoints.net/U+1D455 (<reserved>)
    end
  end
end
