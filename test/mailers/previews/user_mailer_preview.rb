class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    dmail = User.admins.first.dmails.first
    UserMailer.dmail_notice(dmail)
  end

  def password_reset
    user = User.find(params[:id])
    UserMailer.password_reset(user)
  end

  def email_change_confirmation
    user = User.find(params[:id])
    UserMailer.email_change_confirmation(user)
  end

  def welcome_user
    user = User.find(params[:id])
    UserMailer.welcome_user(user)
  end
end
