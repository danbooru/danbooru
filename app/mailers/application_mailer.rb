# frozen_string_literal: true

# The base class for emails sent by Danbooru.
#
# @see https://guides.rubyonrails.org/action_mailer_basics.html
class ApplicationMailer < ActionMailer::Base
  helper :application
  helper :users
  include UsersHelper

  default from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.contact_email}>", content_type: "text/html"

  def mail(user, require_verified_email:, **options)
    # https://www.rfc-editor.org/rfc/rfc8058#section-3.1
    #
    # A mail receiver can do a one-click unsubscription by performing an HTTPS POST to the HTTPS URI in the
    # List-Unsubscribe header. It sends the key/value pair in the List-Unsubscribe-Post header as the request body.
    # The List-Unsubscribe-Post header MUST contain the single key/value pair "List-Unsubscribe=One-Click".
    headers["List-Unsubscribe"] = "<#{disable_email_notifications_url(user)}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"

    message = super(to: user.email_address&.address, **options)
    message.perform_deliveries = user.can_receive_email?(require_verified_email: require_verified_email)
    message
  end
end
