# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # The email sent when a user receives a DMail.
  def dmail_notice(dmail)
    @dmail = dmail
    @user = dmail.to
    mail(
      @user,
      from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.notification_email}>",
      subject: "#{Danbooru.config.canonical_app_name}: #{dmail.from.name} sent you a message",
      require_verified_email: true,
    )
  end

  # The email sent when a user requests a password reset.
  def password_reset(user)
    @user = user
    mail(
      @user,
      from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.account_security_email}>",
      subject: "#{Danbooru.config.app_name} password reset request",
      require_verified_email: false,
    )
  end

  # The email sent when a user changes their email address.
  def email_change_confirmation(user)
    @user = user
    mail(
      @user,
      from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.account_security_email}>",
      subject: "Confirm your email address",
      require_verified_email: false,
    )
  end

  # The email sent when a new user signs up with an email address.
  def welcome_user(user)
    @user = user
    mail(
      @user,
      from: "#{Danbooru.config.canonical_app_name} <#{Danbooru.config.welcome_user_email}>",
      subject: "Welcome to #{Danbooru.config.app_name}! Confirm your email address",
      require_verified_email: false,
    )
  end
end
