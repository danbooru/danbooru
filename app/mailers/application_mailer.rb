class ApplicationMailer < ActionMailer::Base
  default from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.contact_email}>", content_type: "text/html"
end
