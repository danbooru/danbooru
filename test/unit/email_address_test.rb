require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase
  context "EmailAddress" do
    context "validation" do
      should allow_value("foo@gmail.com").for(:address)
      should allow_value("FOO@gmail.com").for(:address)
      should allow_value("foo@GMAIL.com").for(:address)
      should allow_value("foo@foo-bar.com").for(:address)
      should allow_value("foo.bar@gmail.com").for(:address)
      should allow_value("foo_bar@gmail.com").for(:address)
      should allow_value("foo+bar@gmail.com").for(:address)
      should allow_value("foo@foo.bar.com").for(:address)
      should allow_value("foo@iki.fi").for(:address)
      should allow_value("foo@ne.jp").for(:address)

      should_not allow_value("foo@example").for(:address)
      should_not allow_value("fooqq@.com").for(:address)
      should_not allow_value('foo"bar"@gmail.com').for(:address)
      should_not allow_value('foo<bar>@gmail.com').for(:address)
      should_not allow_value("foo@foo.-bar.com").for(:address)
      should_not allow_value("foo@127.0.0.1").for(:address)
      should_not allow_value("foo@localhost").for(:address)
    end

    context "normalization" do
      should "normalize email addresses" do
        assert_equal("foo@gmail.com", EmailAddress.new(address: "FOO@GMAIL.com").normalized_address.to_s)
        assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@googlemail.com").normalized_address.to_s)
        assert_equal("foobar@gmail.com", EmailAddress.new(address: "foo.bar@googlemail.com").normalized_address.to_s)
        assert_equal("foobar@gmail.com", EmailAddress.new(address: "foo.bar+nospam@googlemail.com").normalized_address.to_s)
        assert_equal("foobar@gmail.com", EmailAddress.new(address: "Foo.Bar+nospam@Googlemail.com").normalized_address.to_s)
        assert_equal("foo.bar@yahoo.com", EmailAddress.new(address: "Foo.Bar-nospam@yahoo.com").normalized_address.to_s)
      end
    end

    should "fix typos" do
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail.com ").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: " foo@gmail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail.com\n").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@-gmail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@.gmail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail,com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail.com.").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail.co,").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail..com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmailcom").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "mailto:foo@gmail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail.com@gmail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@g,ail.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmai;.com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo@gmail@com").address.to_s)
      assert_equal("foo@gmail.com", EmailAddress.new(address: "foo.@gmail.com").address.to_s)
    end
  end
end
