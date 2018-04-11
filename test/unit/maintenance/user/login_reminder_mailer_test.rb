require "test_helper"

module Maintenance
  module User
    class LoginReminderMailerTest < ActionMailer::TestCase
      context "The login reminder mailer" do
        setup do
          @user = FactoryBot.create(:user)
        end

        should "send the notice" do
          LoginReminderMailer.notice(@user).deliver_now
          assert !ActionMailer::Base.deliveries.empty?
        end
      end
    end
  end
end
