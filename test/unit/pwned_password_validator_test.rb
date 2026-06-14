# frozen_string_literal: true

require "test_helper"

class PwnedPasswordValidatorTest < ActiveSupport::TestCase
  # SHA1 of "password" = 5BAA61E4C9B93F3F0682250B6CF8331B7EE68FD8
  PWNED_SHA1_PREFIX = "5BAA6"
  PWNED_SHA1_SUFFIX = "1E4C9B93F3F0682250B6CF8331B7EE68FD8"

  def stub_pwned_api(prefix, body, status: 200)
    response = ::HTTP::Response.new(status: status, version: "1.1", body: body, request: ::HTTP::Request.new(verb: :get, uri: "https://api.pwnedpasswords.com/range/#{prefix}"))
    Danbooru::Http.any_instance.stubs(:get).returns(response)
  end

  context "PwnedPasswordValidator" do
    should "reject a password that has appeared in a data breach" do
      stub_pwned_api(PWNED_SHA1_PREFIX, "#{PWNED_SHA1_SUFFIX}:3861493\r\nABCDEF1234567890ABCDEF1234567890ABC:5\r\n")

      user = build(:user, password: "password")
      assert_not(user.valid?)
      assert_includes(user.errors[:password], "has appeared in a data breach and can't be used")
    end

    should "accept a password that has not appeared in a data breach" do
      stub_pwned_api("2AF12", "1234567890ABCDEF1234567890ABCDEF123:1\r\n")

      user = build(:user, password: "super-unique-passphrase-#{SecureRandom.hex}")
      assert(user.valid?)
    end

    should "accept the password if the API is unreachable" do
      Danbooru::Http.any_instance.stubs(:get).raises(HTTP::ConnectionError)

      user = build(:user, password: "password")
      assert(user.valid?)
    end

    should "accept the password if the API returns an error" do
      stub_pwned_api(PWNED_SHA1_PREFIX, "", status: 503)

      user = build(:user, password: "password")
      assert(user.valid?)
    end
  end
end
