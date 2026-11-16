require "test_helper"

class DanbooruLoggerTest < ActiveSupport::TestCase
  context "DanbooruLogger.log" do
    should "log exceptions that were never raised" do
      assert_nothing_raised { DanbooruLogger.log(StandardError.new("not raised")) }
    end
  end
end
