class ReportMailer < ActionMailer::Base
  default :host => Danbooru.config.server_host, :from => Danbooru.config.contact_email, :content_type => "text/html"

  def moderator_report(email)
    mail(:to => email, :subject => "#{Danbooru.config.app_name} - Moderator Report")
  end
end
