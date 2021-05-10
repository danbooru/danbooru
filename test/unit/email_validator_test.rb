require 'test_helper'

class EmailValidatorTest < ActiveSupport::TestCase
  context "EmailValidator" do
    setup do
      EmailValidator.stubs(:smtp_enabled?).returns(true)
    end

    context "#undeliverable?" do
      should "return good addresses as deliverable" do
        assert_equal(false, EmailValidator.undeliverable?("webmaster@danbooru.donmai.us"))
        assert_equal(false, EmailValidator.undeliverable?("noizave+spam@gmail.com"))
      end

      should "return nonexistent domains as undeliverable" do
        assert_equal(true, EmailValidator.undeliverable?("nobody@does.not.exist.donmai.us"))
      end

      # XXX these tests are known to fail if your network blocks port 25.
      should_eventually "return nonexistent addresses as undeliverable" do
        assert_equal(true, EmailValidator.undeliverable?("does.not.exist.13yoigo34iy@gmail.com"))
        assert_equal(true, EmailValidator.undeliverable?("does.not.exist.13yoigo34iy@outlook.com"))
        assert_equal(true, EmailValidator.undeliverable?("does.not.exist.13yoigo34iy@hotmail.com"))
      end
    end
  end
end
