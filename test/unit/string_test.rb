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

  context "String#startcase" do
    should "work" do
      assert_equal("2Girls", "2girls".startcase)
      assert_equal("Bad Pixiv Id", "bad pixiv id".startcase) # XXX wrong, should be "Bad Pixiv ID"
      assert_equal("K-On!", "k-on!".startcase)
      assert_equal(".Hack//", ".hack//".startcase)
      assert_equal("Re:Zero", "re:zero".startcase)
      assert_equal("#Compass", "#compass".startcase)
      assert_equal(".Hack//G.U.", ".hack//g.u.".startcase)
      assert_equal("Me!Me!Me!", "me!me!me!".startcase)
      assert_equal("D.Gray-Man", "d.gray-man".startcase)
      assert_equal("Steins;Gate", "steins;gate".startcase)
      assert_equal("Tiger & Bunny", "tiger & bunny".startcase)
      assert_equal("Ssss.Gridman", "ssss.gridman".startcase) # XXX wrong, should be "SSSS.Gridman"
      assert_equal("Yu-Gi-Oh! 5D's", "yu-gi-oh! 5d's".startcase)
      assert_equal(%{Don't Say "Lazy"}, %q{don't say "lazy"}.startcase)
      assert_equal("Jack-O'-Lantern", "jack-o'-lantern".startcase)
      assert_equal("Miqo'te", "miqo'te".startcase)
      assert_equal("Ninomae Ina'nis", "ninomae ina'nis".startcase)
      assert_equal("D.Va (Overwatch)", "d.va (overwatch)".startcase)
      assert_equal("Rosario+Vampire", "rosario+vampire".startcase)
      assert_equal("Yorha No. 2 Type B", "yorha no. 2 type b".startcase)
      assert_equal("Jeanne D'arc Alter (Ver. Shinjuku 1999) (Fate)", "jeanne d'arc alter (ver. shinjuku 1999) (fate)".startcase) # XXX wrong, should be "d'Arc"
      assert_equal("Kaguya-Sama Wa Kokurasetai ~Tensai-Tachi No Renai Zunousen~", "kaguya-sama wa kokurasetai ~tensai-tachi no renai zunousen~".startcase) # XXX wrong
      assert_equal("Nyoro~N", "nyoro~n".startcase) # XXX wrong, should be "Nyoro~n"
      assert_equal(":O", ":o".startcase)
      assert_equal("O_O", "o_o".startcase)
      assert_equal("Http_User_Agent", "HTTP_USER_AGENT".startcase)
    end
  end
end
