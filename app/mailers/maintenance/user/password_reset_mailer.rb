module Maintenance
  module User
    class PasswordResetMailer < ActionMailer::Base
      def reset_request(user, nonce)
        @user = user
        @nonce = nonce
        mail(:to => @user.email, :subject => "#{Danbooru.config.app_name} password reset request", :from => Danbooru.config.contact_email)
      end
      
      def confirmation(user, new_password)
        @user = user
        @new_password = new_password
        mail(:to => @user.email, :subject => "#{Danbooru.config.app_name} password reset confirmation", :from => Danbooru.config.contact_email)
      end
    end
  end
end
