class UserMailer < ActionMailer::Base
  default :host => Danbooru.config.server_host, :from => Danbooru.config.contact_email, :content_type => "text/html"

  def password_reset(user, new_password)
    @user = user
    @new_password = new_password
    mail(:to => @user.email, :subject => "#{Danbooru.config.app_name} - Password Reset")
  end
  
  def name_reminder(user)
    @user = user
    mail(:to => user.email, :subject => "#{Danbooru.config.app_name} - Name Reminder")
  end
  
  def deletion(user)
    @user = user
    mail(:to => user.email, :subject => "#{}")
  end
  
  def dmail_notice(dmail)
    @dmail = dmail
    mail(:to => dmail.to.email, :subject => "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")    
  end
end
