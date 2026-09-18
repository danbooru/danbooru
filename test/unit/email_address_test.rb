require "test_helper"

class EmailAddressTest < ActiveSupport::TestCase
  context "EmailAddress" do
    context "validation" do
      subject { build(:email_address) }

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
      should_not allow_value("foo<bar>@gmail.com").for(:address)
      should_not allow_value("foo@foo.-bar.com").for(:address)
      should_not allow_value("foo@127.0.0.1").for(:address)
      should_not allow_value("foo@localhost").for(:address)
      should_not allow_value("#{"x" * 100}@example.com").for(:address)

      should allow_value("webmaster@danbooru.donmai.us").for(:address).on(:deliverable) # valid MX record
      should_not allow_value("nobody@betabooru.donmai.us").for(:address).on(:deliverable) # no MX record
      should_not allow_value("nobody@invalid.donmai.us").for(:address).on(:deliverable) # domain doesn't exist
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

    context "#verify!" do
      setup do
        @request = ActionDispatch::TestRequest.create("REMOTE_ADDR" => Faker::Internet.public_ip_v4_address, "HTTP_USER_AGENT" => Faker::Internet.user_agent)
        @request.session = { session_id: SecureRandom.hex(16), login_id: create(:login_session).id }
      end

      should "record a user event" do
        email_address = create(:email_address, is_verified: false, request: @request)
        email_address.verify!

        assert_equal(true, email_address.user.user_events.email_verification.exists?)
      end

      should "not record a duplicate user event" do
        email_address = create(:email_address, is_verified: false, request: @request)
        email_address.verify!
        email_address.verify!

        assert_equal(1, email_address.user.user_events.email_verification.count)
      end

      should "record an account_verification event for a restricted user" do
        user = create(:restricted_user)
        email_address = create(:email_address, user: user, address: "test@gmail.com", is_verified: false, request: @request)

        email_address.verify!

        assert_equal(true, user.user_events.account_verification.exists?)
        assert_equal(User::Levels::MEMBER, user.reload.level)
      end

      should "not record an account_verification event for an unrestricted user" do
        user = create(:builder_user)
        email_address = create(:email_address, is_verified: false, request: @request)

        email_address.verify!

        assert_equal(false, user.user_events.account_verification.exists?)
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
