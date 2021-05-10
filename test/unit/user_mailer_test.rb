require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  context "UserMailer" do
    setup do
      @user = create(:user, email_address: build(:email_address))
    end

    context "dmail_notice method" do
      should "work" do
        @dmail = create(:dmail, owner: @user, to: @user)
        mail = UserMailer.dmail_notice(@dmail)
        assert_emails(1) { mail.deliver_now }
      end
    end

    context "password_reset method" do
      should "work" do
        mail = UserMailer.password_reset(@user)
        assert_emails(1) { mail.deliver_now }
      end
    end

    context "email_change_confirmation method" do
      should "work" do
        mail = UserMailer.email_change_confirmation(@user)
        assert_emails(1) { mail.deliver_now }
      end
    end

    context "welcome_user method" do
      should "work" do
        mail = UserMailer.welcome_user(@user)
        assert_emails(1) { mail.deliver_now }
      end
    end
  end
end
