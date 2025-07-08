require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  def self.to_ips(ips)
    ips.map { |ip| Danbooru::IpAddress.parse(ip) }
  end

  context "ApiKey:" do
    setup do
      @user = create(:user)
      @api_key = create(:api_key, user: @user)
    end

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
        create_list(:api_key, 20, user: user)
        api_key = build(:api_key, user: user)

        assert_equal(false, api_key.valid?)
        assert_includes(api_key.errors[:base], "You can't have more than 20 API keys.")
      end
    end

    should "generate a unique key" do
      assert_not_nil(@api_key.key)
    end

    should "authenticate via api key" do
      assert_equal([@user, @api_key], @user.authenticate_api_key(@api_key.key))
    end

    should "not authenticate with the wrong api key" do
      assert_equal(false, @user.authenticate_api_key("xxx"))
    end

    should "not authenticate with the wrong name" do
      assert_equal(false, create(:user).authenticate_api_key(@api_key.key))
    end
  end
end
