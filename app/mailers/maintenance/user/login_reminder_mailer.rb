module Maintenance
  module User
    class LoginReminderMailer < ActionMailer::Base
      def notice(user)
        @user = user
        if user.email.present?
          mail(:to => user.email, :subject => "#{Danbooru.config.app_name} login reminder", :from => Danbooru.config.contact_email)
        end
      end
    end
  end
end
