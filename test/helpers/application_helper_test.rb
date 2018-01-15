require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  context "The application helper" do
    context "format_text method" do
      should "not raise an exception for invalid DText" do
        dtext = "* a\n" * 513

        assert_nothing_raised { format_text(dtext) }
        assert_equal("", format_text(dtext))
      end
    end
  end
end
