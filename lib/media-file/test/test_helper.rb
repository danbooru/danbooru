# frozen_string_literal: true

require_relative "../lib/media_file"
require "active_support/test_case"
require "minitest/autorun"
require "mocha/minitest"
require "shoulda-context"
require_relative "media_file_helper"

# The tests use paths relative to the root of the gem, like "test/files/jpg/test.jpg".
Dir.chdir(File.expand_path("..", __dir__))

ActiveSupport.test_order = :random

# Tests that check what's logged use `MediaFile.logger.expects`.
MediaFile.config.logger = Logger.new(File::NULL)

class ActiveSupport::TestCase
  include MediaFileTestHelper

  parallelize

  # Give each worker its own temp dir, so tests running at the same time can't see each other's temp files.
  parallelize_setup do |worker|
    ENV["TMPDIR"] = Dir.mktmpdir("media-file-test-worker-#{worker}-")
  end

  parallelize_teardown do
    FileUtils.rm_rf(ENV.fetch("TMPDIR")) if ENV["TMPDIR"]&.include?("media-file-test-worker-")
  end
end
