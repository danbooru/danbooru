require 'test_helper'

class UserPasswordResetNonceTest < ActiveSupport::TestCase
  context "Creating a new nonce" do
    context "with a valid email" do
      setup do
        @user = FactoryBot.create(:user, :email => "aaa@b.net")
        @nonce = FactoryBot.create(:user_password_reset_nonce, :email => @user.email)
      end

      should "validate" do
        assert_equal([], @nonce.errors.full_messages)
      end

      should "populate the key with a random string" do
        assert_equal(32, @nonce.key.size)
      end

      should "reset the password when reset" do
        @nonce.user.expects(:reset_password_and_deliver_notice)
        @nonce.reset_user!
      end
    end

    context "with a blank email" do
      setup do
        @user = FactoryBot.create(:user, :email => "")
        @nonce = UserPasswordResetNonce.new(:email => "")
      end

      should "not validate" do
        @nonce.save
        assert_equal(["Email can't be blank", "Email is invalid"], @nonce.errors.full_messages.sort)
      end
    end

    context "with an invalid email" do
      setup do
        @nonce = UserPasswordResetNonce.new(:email => "z@z.net")
      end

      should "not validate" do
        @nonce.save
        assert_equal(["Email is invalid"], @nonce.errors.full_messages)
      end
    end
  end
end
