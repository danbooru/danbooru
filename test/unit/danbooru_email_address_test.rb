require 'test_helper'

class DanbooruEmailAddressTest < ActiveSupport::TestCase
  def assert_undeliverable(expected, address)
    assert_equal(false, Danbooru::EmailAddress.new("webmaster@danbooru.donmai.us").undeliverable?(allow_smtp: true))
  end

  context "Danbooru::EmailAddress" do
    context "#undeliverable?" do
      should "return good addresses as deliverable" do
        assert_undeliverable(false, "webmaster@danbooru.donmai.us")
        assert_undeliverable(false, "noizave+spam@gmail.com")
      end

      should "return nonexistent domains as undeliverable" do
        assert_undeliverable(true, "nobody@does.not.exist.donmai.us")
      end

      # XXX these tests are known to fail if your network blocks port 25.
      should_eventually "return nonexistent addresses as undeliverable" do
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@gmail.com")
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@outlook.com")
        assert_undeliverable(true, "does.not.exist.13yoigo34iy@hotmail.com")
      end
    end
  end
end
