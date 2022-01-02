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

      should_not allow_value("foo@gmail.com ").for(:address)
      should_not allow_value(" foo@gmail.com").for(:address)
      should_not allow_value("foo@-gmail.com").for(:address)
      should_not allow_value("foo@.gmail.com").for(:address)
      should_not allow_value("foo@gmail").for(:address)
      should_not allow_value("foo@gmail.").for(:address)
      should_not allow_value("foo@gmail,com").for(:address)
      should_not allow_value("foo@gmail.com.").for(:address)
      should_not allow_value("foo@gmail.co,").for(:address)
      should_not allow_value("fooqq@.com").for(:address)
      should_not allow_value("foo@gmail..com").for(:address)
      should_not allow_value("foo@gmailcom").for(:address)
      should_not allow_value("mailto:foo@gmail.com").for(:address)
      should_not allow_value('foo"bar"@gmail.com').for(:address)
      should_not allow_value('foo<bar>@gmail.com').for(:address)
      should_not allow_value("foo@gmail.com@gmail.com").for(:address)
      should_not allow_value("foo@g,ail.com").for(:address)
      should_not allow_value("foo@gmai;.com").for(:address)
      should_not allow_value("foo@gmail@com").for(:address)
      should_not allow_value("foo@gmail.c").for(:address)
      should_not allow_value("foo@foo.-bar.com").for(:address)
      should_not allow_value("foo@127.0.0.1").for(:address)
      should_not allow_value("foo@localhost").for(:address)
    end
  end
end
