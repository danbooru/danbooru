# frozen_string_literal: true

require "test_helper"

class ZxcvbnPasswordValidatorTest < ActiveSupport::TestCase
  context "ZxcvbnPasswordValidator" do
    should "reject a common weak password" do
      user = build(:user, password: "password")
      assert_not(user.valid?)
      assert(user.errors[:password].any? { |e| e.include?("weak") || e.include?("common") })
    end

    should "reject a short dictionary word" do
      user = build(:user, password: "letmein")
      assert_not(user.valid?)
    end

    should "accept a strong passphrase" do
      user = build(:user, password: "correct horse battery staple")
      assert(user.valid?, "Expected passphrase to be valid, got errors: #{user.errors.full_messages}")
    end

    should "include the zxcvbn warning in the error message when available" do
      user = build(:user, password: "qwerty")
      user.valid?
      assert(user.errors[:password].any? { |e| e.match?(/common|keyboard|sequence|row/i) })
    end
  end
end
