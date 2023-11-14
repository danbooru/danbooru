class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    user = params[:id].present? ? User.find(params[:id]) : User.owner
    dmail = Dmail.received.order(id: :desc).offset(279).first
    UserMailer.dmail_notice(dmail)
  end

  def password_reset
    user = params[:id].present? ? User.find(params[:id]) : User.owner
    UserMailer.password_reset(user)
  end

  def email_change_confirmation
    user = params[:id].present? ? User.find(params[:id]) : User.owner
    UserMailer.email_change_confirmation(user)
  end

  def welcome_user
    user = params[:id].present? ? User.find(params[:id]) : User.owner
    UserMailer.welcome_user(user)
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
end
