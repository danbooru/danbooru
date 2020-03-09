class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    dmail = User.admins.first.dmails.first
    UserMailer.dmail_notice(dmail)
  end

  def password_reset
    user = User.find(params[:id])
    UserMailer.password_reset(user)
  end
end
