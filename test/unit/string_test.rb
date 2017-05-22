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
end
