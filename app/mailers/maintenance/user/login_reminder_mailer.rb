module Maintenance
  module User
    class LoginReminderMailer < ActionMailer::Base
      def notice(user)
        @user = user
        mail(:to => user.email, :subject => "#{Danbooru.config.app_name} login reminder")
      end
    end
  end
end
