class UserMailer < ApplicationMailer
  add_template_helper ApplicationHelper
  add_template_helper UsersHelper

  def dmail_notice(dmail)
    @dmail = dmail
    mail to: dmail.to.email_with_name, subject: "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}"
  end

  def password_reset(user)
    @user = user
    mail to: @user.email_with_name, subject: "#{Danbooru.config.app_name} password reset request"
  end

  def email_change_confirmation(user)
    @user = user
    mail to: @user.email_with_name, subject: "Confirm your email address"
  end

  def welcome_user(user)
    @user = user
    mail to: @user.email_with_name, subject: "Welcome to #{Danbooru.config.app_name}! Confirm your email address"
  end
end
