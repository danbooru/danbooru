class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    dmail = user.dmails.received.last

    UserMailer.dmail_notice(dmail)
  end

  def password_reset
    UserMailer.password_reset(user)
  end

  def email_change_confirmation
    UserMailer.email_change_confirmation(user)
  end

  def welcome_user
    UserMailer.welcome_user(user)
  end

  def login_verification
    user_event = user.user_events.login_pending_verification.last

    UserMailer.login_verification(user_event)
  end

  def send_backup_code
    UserMailer.send_backup_code(user)
  end

  def dmca_complaint
    dmca = {
      name: "John Doe",
      email: "test@example.com",
      address: "123 Fake Street",
      infringing_urls: "https://example.com/1.html\nhttps://example.com/2.html",
      original_urls: "https://google.com/1.html\nhttps://google.com/2.html",
      proof: "source: me",
      signature: "John Doe",
    }

    UserMailer.with(dmca: dmca).dmca_complaint(to: dmca[:email])
  end

  private

  def user
    params[:id].present? ? User.find(params[:id]) : User.owner
  end
end
