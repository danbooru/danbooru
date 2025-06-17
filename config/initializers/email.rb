# frozen_string_literal: true

# Configures mail delivery settings.

mail_delivery_url = Danbooru.config.mail_delivery_url

if mail_delivery_url.present?
  url = Danbooru::URL.parse!(mail_delivery_url, schemes: %w[smtp smtps])
  params = url.params.dup.symbolize_keys
  default_port = (url.scheme == "smtp") ? 587 : 465

  Rails.application.config.action_mailer.raise_delivery_errors = true
  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = {
    address: url.host,
    port: url.port || default_port,
    user_name: Addressable::URI.unencode(url.user),
    password: Addressable::URI.unencode(url.password),
    enable_starttls: params.delete(:enable_starttls)&.truthy?,
    enable_starttls_auto: params.delete(:enable_starttls_auto)&.truthy?,
    openssl_verify_mode: params.delete(:openssl_verify_mode)&.to_sym,
    authentication: params.delete(:authentication)&.to_sym,
    tls: params.delete(:tls) || url.scheme == "smtps",
    open_timeout: params.delete(:open_timeout)&.to_i || 5,
    read_timeout: params.delete(:read_timeout)&.to_i || 5,
    **params,
  }.compact
end
