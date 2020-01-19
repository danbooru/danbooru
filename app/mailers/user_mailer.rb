class UserMailer < ActionMailer::Base
  add_template_helper ApplicationHelper
  add_template_helper UsersHelper
  default :from => Danbooru.config.contact_email, :content_type => "text/html"

  def dmail_notice(dmail)
    @dmail = dmail
    mail(:to => "#{dmail.to.name} <#{dmail.to.email}>", :subject => "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")
  end
end
