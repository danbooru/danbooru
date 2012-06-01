require "test_helper"

module Maintenance
  module User
    class LoginReminderMailerTest < ActionMailer::TestCase
      context "The login reminder mailer" do
        setup do
          @user = FactoryGirl.create(:user)
        end
        
        should "send the notie" do
          LoginReminderMailer.notice(@user).deliver
          assert !ActionMailer::Base.deliveries.empty?
        end
      end
    end
  end
end
