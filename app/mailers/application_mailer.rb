# frozen_string_literal: true

# The base class for emails sent by Danbooru.
#
# @see https://guides.rubyonrails.org/action_mailer_basics.html
# @see app/logical/email_interceptor.rb
class ApplicationMailer < ActionMailer::Base
  helper :application
  helper :users
  include UsersHelper

  default from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.contact_email}>", content_type: "text/html"
  default "Message-ID": -> { "<#{SecureRandom.uuid}@#{Danbooru.config.hostname}>" }

  def mail(user, require_verified_email:, **options)
    # https://www.rfc-editor.org/rfc/rfc8058#section-3.1
    #
    # A mail receiver can do a one-click unsubscription by performing an HTTPS POST to the HTTPS URI in the
    # List-Unsubscribe header. It sends the key/value pair in the List-Unsubscribe-Post header as the request body.
    # The List-Unsubscribe-Post header MUST contain the single key/value pair "List-Unsubscribe=One-Click".
    headers["List-Unsubscribe"] = "<#{disable_email_notifications_url(user)}>"
    headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"

    headers["X-Danbooru-User"] = "#{user.name} <#{user_url(user)}>"
    if params.to_h[:request]
      headers["X-Danbooru-URL"] = params[:request][:url]
      headers["X-Danbooru-IP"] = params[:request][:remote_ip]
      headers["X-Danbooru-Session"] = params[:request][:session_id]
      headers["X-Request-Id"] = params[:request][:request_id]
    end

    headers(params.to_h[:headers].to_h)

    message = super(to: user.email_address&.address, **options)
    message.perform_deliveries = user.can_receive_email?(require_verified_email: require_verified_email)
    message
  end

  def self.with_request(request)
    with(
      request: {
        url: "#{request.method} #{request.url}",
        remote_ip: request.remote_ip.to_s,
        request_id: request.request_id.to_s,
        session_id: request.session.id.to_s,
      }
    )
  end
end
