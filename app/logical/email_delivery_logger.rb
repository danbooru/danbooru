# frozen_string_literal: true

# This is called just before an email is sent out to log information about the email.
#
# @see config/application.rb (config.action_mailer.interceptors)
# @see https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-emails
class EmailDeliveryLogger
  def self.delivering_email(email)
    DanbooruLogger.info("Delivering email to #{email.to}", headers: email.headers)
  end
end
