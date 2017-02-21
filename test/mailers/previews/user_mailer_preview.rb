class UserMailerPreview < ActionMailer::Preview
  def dmail_notice
    dmail = User.admins.first.dmails.first
    UserMailer.dmail_notice(dmail)
  end
end
