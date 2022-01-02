# frozen_string_literal: true

# The base class for emails sent by Danbooru.
#
# @see https://guides.rubyonrails.org/action_mailer_basics.html
class ApplicationMailer < ActionMailer::Base
  default from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.contact_email}>", content_type: "text/html"

  def mail(user, require_verified_email:, **options)
    message = super(to: user.email_address&.address, **options)
    message.perform_deliveries = user.can_receive_email?(require_verified_email: require_verified_email)
    message
  end
end
