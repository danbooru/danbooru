require "test_helper"

class ReadOnlyModeConfigTest < ActiveSupport::TestCase
  should "parse the DANBOORU_READ_ONLY_MODE environment variable" do
    config = Danbooru::EnvironmentConfiguration.new(Danbooru::Configuration.new)

    ENV["DANBOORU_READ_ONLY_MODE"] = "true"
    assert_equal(true, config.read_only_mode?)

    ENV["DANBOORU_READ_ONLY_MODE"] = "false"
    assert_equal(false, config.read_only_mode?)
  ensure
    ENV.delete("DANBOORU_READ_ONLY_MODE")
  end
end
