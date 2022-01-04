# frozen_string_literal: true

module UsersHelper
  def unread_dmail_indicator(user)
    "(#{user.unread_dmail_count})" if user.unread_dmail_count > 0
  end

  def has_unread_dmails?(user)
    user.unread_dmail_count > 0 && latest_unread_dmail(user).present? && (cookies[:hide_dmail_notice].to_i < latest_unread_dmail(user).id)
  end

  def latest_unread_dmail(user)
    user.dmails.active.unread.first
  end

  def disable_email_notifications_url(user)
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, serializer: JSON, digest: "SHA256")
    sig = verifier.generate(user.id.to_s)

    maintenance_user_email_notification_url(user_id: user.id, sig: sig)
  end

  def email_verification_url(user)
    verify_user_email_url(user, email_verification_key: user.email_address&.verification_key)
  end
end
