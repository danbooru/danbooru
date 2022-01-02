# frozen_string_literal: true

class UserMailer < ApplicationMailer
  helper :application
  helper :users

  # The email sent when a user receives a DMail.
  def dmail_notice(dmail)
    @dmail = dmail
    mail(dmail.to, require_verified_email: true, subject: "#{Danbooru.config.app_name} - Message received from #{dmail.from.name}")
  end

  # The email sent when a user requests a password reset.
  def password_reset(user)
    @user = user
    mail(@user, require_verified_email: false, subject: "#{Danbooru.config.app_name} password reset request")
  end

  # The email sent when a user changes their email address.
  def email_change_confirmation(user)
    @user = user
    mail(@user, require_verified_email: false, subject: "Confirm your email address")
  end

  # The email sent when a new user signs up with an email address.
  def welcome_user(user)
    @user = user
    mail(@user, require_verified_email: false, subject: "Welcome to #{Danbooru.config.app_name}! Confirm your email address")
  end
end
