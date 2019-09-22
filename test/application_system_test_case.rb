require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include SystemTestHelper
  driven_by :selenium, using: :headless_firefox, screen_size: [1400, 1400]
end
