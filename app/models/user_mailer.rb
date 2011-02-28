class UserMailer < ActionMailer::Base
  default :host => Danbooru.config.server_host, :from => Danbooru.config.contact_email, :content_type => "text/html"

  def dmail_notice(dmail)
    @dmail = dmail
    mail(:to => dmail.to.email, :subject => "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")    
  end
end
