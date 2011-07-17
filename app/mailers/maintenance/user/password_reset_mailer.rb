module Maintenance
  module User
    class PasswordResetMailer < ActionMailer::Base
      def request(user)
        @user = user
        mail(:to => @user.email, :subject => "#{Danbooru.config.app_name} password reset request")
      end
      
      def confirmation(user)
        @user = user
        mail(:to => @user.email, :subject => "#{Danbooru.config.app_name} password reset confirmation")
      end
    end
  end
end
