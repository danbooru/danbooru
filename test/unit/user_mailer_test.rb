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
        assert_not_nil(mail.header["List-Unsubscribe"])
        assert_emails(1) { mail.deliver_now }
      end

      should "not send an email for a user without an email address" do
        @user = create(:user)
        @dmail = create(:dmail, owner: @user, to: @user)
        mail = UserMailer.dmail_notice(@dmail)
        assert_emails(0) { mail.deliver_now }
      end

      should "not send an email for a user with an undeliverable address" do
        @user = create(:user, email_address: build(:email_address, is_deliverable: false))
        @dmail = create(:dmail, owner: @user, to: @user)
        mail = UserMailer.dmail_notice(@dmail)
        assert_emails(0) { mail.deliver_now }
      end

      should "not send an email for a user with an unverified address" do
        @user = create(:user, email_address: build(:email_address, is_verified: false))
        @dmail = create(:dmail, owner: @user, to: @user)
        mail = UserMailer.dmail_notice(@dmail)
        assert_emails(0) { mail.deliver_now }
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

      should "not fail for a user without an email address" do
        @user = create(:user)
        mail = UserMailer.email_change_confirmation(@user)
        assert_emails(0) { mail.deliver_now }
      end
    end

    context "welcome_user method" do
      should "work" do
        mail = UserMailer.welcome_user(@user)
        assert_emails(1) { mail.deliver_now }
      end

      should "not fail for a user without an email address" do
        @user = create(:user)
        mail = UserMailer.welcome_user(@user)
        assert_emails(0) { mail.deliver_now }
      end
    end

    context "dmail_complaint method" do
      should "work" do
        dmca = {
          name: "John Doe",
          email: "test@example.com",
          address: "123 Fake Street",
          infringing_urls: "https://example.com/1.html\nhttps://example.com/2.html",
          original_urls: "https://google.com/1.html\nhttps://google.com/2.html",
          proof: "source: me",
          signature: "John Doe",
        }

        mail = UserMailer.with(dmca: dmca).dmca_complaint(to: dmca[:email])
        assert_emails(1) { mail.deliver_now }
      end
    end
  end
end
