require "test_helper"

class ApiKeyTest < ActiveSupport::TestCase
  def self.to_ips(ips)
    ips.map { |ip| Danbooru::IpAddress.parse(ip) }
  end

  context "ApiKey:" do
    context "During validation" do
      subject { build(:api_key) }

      context "of permissions" do
        should normalize_attribute(:permissions).from(["posts:index", " "]).to(["posts:index"])

        should allow_value([]).for(:permissions)
        should allow_value(["posts:index"]).for(:permissions)
        should allow_value(["posts:index", "posts:show"]).for(:permissions)

        should_not allow_value(["blah"]).for(:permissions)
        should_not allow_value(["posts:blah"]).for(:permissions)
        should_not allow_value(["blah:index"]).for(:permissions)
      end

      context "of IP addresses" do
        should normalize_attribute(:permitted_ip_addresses).from(%w[1.2.3.4 1.2.3.4/32]).to(to_ips(["1.2.3.4"]))
        should normalize_attribute(:permitted_ip_addresses).from(%w[5.6.7.8 1.2.3.4]).to(to_ips(["1.2.3.4", "5.6.7.8"]))
        should normalize_attribute(:permitted_ip_addresses).from(%w[1.2.3.4/16 5.6.7.8/24]).to(to_ips(["5.6.7.8/24", "1.2.3.4/16"]))
        should normalize_attribute(:permitted_ip_addresses).from(%w[1.2.3.4/24 1.2.3.4/24]).to(to_ips(["1.2.3.4/24"]))
        should normalize_attribute(:permitted_ip_addresses).from([nil, "1.2.3.4/16", "5.6.7.8/24"]).to(to_ips(["5.6.7.8/24", "1.2.3.4/16"]))
        should normalize_attribute(:permitted_ip_addresses).from([nil, "", " "]).to(to_ips([]))

        should allow_value([]).for(:permitted_ip_addresses)
        should allow_value(["1.2.3.4"]).for(:permitted_ip_addresses)
        should allow_value(["1.2.3.4/24"]).for(:permitted_ip_addresses)
        should allow_value(["0.0.0.0/0"]).for(:permitted_ip_addresses)
        should allow_value(["2600::1/64"]).for(:permitted_ip_addresses)
        should allow_value(["1.2.3.4/24 5.6.7.8/24"]).for(:permitted_ip_addresses)
        should allow_value(20.times.map { |n| "1.2.3.#{n}" }).for(:permitted_ip_addresses)

        should_not allow_value(["127.0.0.1"]).for(:permitted_ip_addresses)
        should_not allow_value(["192.168.0.0/16"]).for(:permitted_ip_addresses)
        should_not allow_value(["10.0.0.0/8"]).for(:permitted_ip_addresses)
        should_not allow_value(["1.2.0.0/16", "1.2.3.0/24"]).for(:permitted_ip_addresses)
        should_not allow_value(["0.0.0.0"]).for(:permitted_ip_addresses)
        should_not allow_value(["::"]).for(:permitted_ip_addresses)
        should_not allow_value(21.times.map { |n| "1.2.3.#{n}" }).for(:permitted_ip_addresses)

        # should_not allow_value(["blah"]).for(:permitted_ip_addresses)
        # should_not allow_value(["1.2.3.4/64"]).for(:permitted_ip_addresses)
      end

      context "of name" do
        should normalize_attribute(:name).from(" foo\tbar ").to("foo bar")
        should normalize_attribute(:name).from(" ").to("")
        should normalize_attribute(:name).from("\t\n\u200B").to("")

        should allow_value("").for(:name)
        should_not allow_value("x" * 101).for(:name)
      end

      should "not allow more than 20 API keys per user" do
        user = create(:user)
        create_list(:api_key, 20, user: user) # rubocop:disable FactoryBot/ExcessiveCreateList
        api_key = build(:api_key, user: user)

        assert_equal(false, api_key.valid?)
        assert_includes(api_key.errors[:base], "You can't have more than 20 API keys.")
      end
    end

    context "when creating an API key" do
      setup do
        @user = create(:user)
        @request = ActionDispatch::TestRequest.create("REMOTE_ADDR" => Faker::Internet.public_ip_v4_address, "HTTP_USER_AGENT" => Faker::Internet.user_agent)
        @request.session = { session_id: SecureRandom.hex(16), login_id: create(:login_session).id }
        @api_key = create(:api_key, user: @user, request: @request)
      end

      should "record a user event" do
        assert_equal(true, @user.user_events.api_key_create.exists?)
      end

      should "send a dmail notification" do
        assert_equal(true, @user.dmails.received.exists?(from: User.system, title: "API key created"))
      end

      should "create a permanent key by default" do
        api_key = create(:api_key, user: create(:user))

        assert_nil(api_key.expires_at)
        assert_equal(true, api_key.permanent?)
        assert_equal(false, api_key.expired?)
      end

      should "use the selected expiration date when expiry is checked" do
        date = 2.weeks.from_now.to_date
        api_key = create(:api_key, user: create(:user), expires: true, expires_on: date)

        assert_equal(date.end_of_day, api_key.expires_at)
        assert_equal(false, api_key.permanent?)
      end

      should "say a permanent key never expires in the dmail" do
        create(:api_key, user: @user)
        dmail = @user.dmails.received.where(title: "API key created").reorder(id: :desc).first

        assert_includes(dmail.body, "Expires: Never")
      end

      should "allow updating an expired key without changing its expiry" do
        api_key = create(:api_key, user: create(:user), expires_at: 2.days.from_now.change(hour: 12))

        travel_to(2.years.from_now) do
          expired_key = ApiKey.find(api_key.id)
          assert_equal(true, expired_key.update(name: "blah", expires: true, expires_on: expired_key.expires_on))
        end
      end

      should "include permanent keys in active keys" do
        api_key = create(:api_key, user: create(:user), expires: false)

        assert_includes(ApiKey.active, api_key)
        assert_not_includes(ApiKey.expired, api_key)
      end

      should "not prune permanent keys" do
        api_key = create(:api_key, user: create(:user), expires: false)

        travel_to(2.years.from_now) { ApiKey.prune! }

        assert_equal(true, ApiKey.exists?(api_key.id))
      end

      should "authenticate with a permanent key many years later" do
        user = create(:user)
        api_key = create(:api_key, user: user, expires: false)

        travel_to(50.years.from_now) do
          assert_equal([user, api_key], user.authenticate_api_key(api_key.key))
        end
      end

      should "not allow an expiration date in the past" do
        api_key = build(:api_key, user: create(:user), expires: true, expires_on: Date.yesterday)

        assert_equal(false, api_key.valid?)
        assert_includes(api_key.errors[:expires_at], "must be in the future")
      end

      should "not change the expiration time when updating other attributes" do
        api_key = create(:api_key, user: create(:user), expires: true, expires_on: Date.tomorrow)
        expires_at = api_key.expires_at

        api_key.update!(name: "blah", expires: true, expires_on: api_key.expires_on)

        assert_equal(expires_at.to_i, api_key.reload.expires_at.to_i)
      end

      should "preserve a non-end-of-day expiration time when updating other attributes" do
        api_key = create(:api_key, user: create(:user), expires_at: 1.year.from_now.change(hour: 12))
        expires_at = api_key.expires_at

        api_key.update!(name: "blah", expires: true, expires_on: api_key.expires_on)

        assert_equal(expires_at.to_i, api_key.reload.expires_at.to_i)
      end

      should "record a user event when updating the key" do
        @api_key.update!(permitted_ip_addresses: ["1.2.3.4"])

        assert_equal(true, @user.user_events.api_key_update.exists?)
      end

      should "record a user event when destroying the key" do
        @api_key.destroy!

        assert_equal(true, @user.user_events.api_key_delete.exists?)
      end

      should "generate a key with the expected prefix" do
        assert_match(/\Adbru_[A-Za-z0-9]+\z/, @api_key.key)
      end

      should "store only a digest of the key" do
        assert_equal(ApiKey.digest(@api_key.key), @api_key.reload.key_digest)
        assert_nil(ApiKey.find(@api_key.id).key)
        assert_not_includes(ApiKey.column_names, "key")
      end

      should "authenticate via api key" do
        assert_equal([@user, @api_key], @user.authenticate_api_key(@api_key.key))
      end

      should "not authenticate via an expired api key" do
        api_key = create(:api_key, user: @user, expires: true, expires_on: Date.tomorrow)

        travel_to(2.years.from_now) do
          assert_equal(false, @user.authenticate_api_key(api_key.key))
        end
      end

      should "not authenticate with the wrong api key" do
        assert_equal(false, @user.authenticate_api_key("xxx"))
      end

      should "not authenticate with the wrong name" do
        assert_equal(false, create(:user).authenticate_api_key(@api_key.key))
      end
    end
  end
end
