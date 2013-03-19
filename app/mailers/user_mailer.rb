class UserMailer < ActionMailer::Base
  default :from => Danbooru.config.contact_email, :content_type => "text/html"

  def dmail_notice(dmail)
    @dmail = dmail
    mail(:to => "#{dmail.to.name} <#{dmail.to.email}>", :subject => "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")
  end

  def upgrade(user, email)
    mail(:to => "#{user.name} <#{email}>", :subject => "#{Danbooru.config.app_name} account upgrade")
  end

  def upgrade_fail(email)
    mail(:to => "#{user.name} <#{email}>", :subject => "#{Danbooru.config.app_name} account upgrade")
  end
end
