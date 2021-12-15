# frozen_string_literal: true

# The base class for emails sent by Danbooru.
#
# @see https://guides.rubyonrails.org/action_mailer_basics.html
class ApplicationMailer < ActionMailer::Base
  default from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.contact_email}>", content_type: "text/html"
end
