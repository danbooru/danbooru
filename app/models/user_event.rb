# frozen_string_literal: true

# A UserEvent is used to track important events related to a user's account,
# such as signups, logins, password changes, etc. A UserEvent is associated
# with a UserSession, which contains the IP and browser information associated
# with the event.

class UserEvent < ApplicationRecord
  extend Memoist

  # Events that were performed by the user while logged in, for tracking the user's authorized IP addresses. This does not
  # include failed login attempts, password reset requests, or other events that may not have been performed by the user.
  AUTHORIZED_EVENTS = %i[
    login login_verification reauthenticate logout user_creation user_deletion user_undeletion
    password_reset password_change email_change totp_enable totp_update totp_disable
    totp_login totp_reauthenticate backup_code_generate backup_code_login backup_code_reauthenticate
  ]

  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :user_id
  attribute :user_session_id
  attribute :category
  attribute :ip_addr, :ip_address
  attribute :session_id, :md5
  attribute :user_agent
  attribute :metadata

  belongs_to :user
  belongs_to :user_session
  belongs_to :ip_geolocation, foreign_key: :ip_addr, primary_key: :ip_addr, optional: true

  enum :category, {
    login: 0,                             # The user successfully logged in. Only used for users without 2FA enabled.
    login_pending_verification: 10,       # The user entered the correct password on the login page, but logged in from a new
                                          # location. Only used for users with a valid email but without 2FA enabled.
    login_verification: 15,               # The user clicked the link in the email sent to verify their new login location.
    reauthenticate: 25,                   # The user entered the correct password on the confirm password page. Only used for users without 2FA enabled.
    failed_login: 50,                     # The user entered an incorrect password on the login page.
    failed_reauthenticate: 75,            # The user entered an incorrect password on the confirm password page.
    logout: 100,
    user_creation: 200,
    user_deletion: 300,
    user_undeletion: 310,
    password_reset_request: 400,          # The user requested a password reset email.
    password_reset: 450,                  # The user changed their password after requesting a password reset email.
    password_change: 500,                 # The user changed their password.
    email_change: 600,
    totp_enable: 700,                     # The user enabled 2FA.
    totp_update: 710,                     # The user changed their 2FA secret.
    totp_disable: 720,                    # The user disabled 2FA.
    totp_login_pending_verification: 730, # The user entered the correct password on the login page, but has not yet entered their 2FA code.
    totp_login: 740,                      # The user successfully entered their password and 2FA code on the login page.
    totp_reauthenticate: 745,             # The user successfully entered their password and 2FA code on the confirm password page.
    totp_failed_login: 750,               # The user entered the correct password, but an incorrect 2FA code or backup code on the login page.
    totp_failed_reauthenticate: 755,      # The user entered the correct password, but an incorrect 2FA code or backup code on the confirm password page.
    backup_code_generate: 800,            # The user generated new backup codes.
    backup_code_login: 840,               # The user successfully entered their password and backup code on the login page.
    backup_code_reauthenticate: 845,      # The user successfully entered their password and backup code on the confirm password page.
  }

  delegate :country, :city, :is_proxy?, to: :ip_geolocation, allow_nil: true

  scope :authorized, -> { where(category: AUTHORIZED_EVENTS) }

  def self.visible(user)
    if user.is_moderator?
      all
    elsif user.is_anonymous?
      none
    else
      where(user: user)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :category, :user, :user_session, :ip_addr, :session_id, :user_agent, :metadata, :ip_geolocation], current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:user, :user_session]
  end

  concerning :ConstructorMethods do
    class_methods do
      # Build an event but don't save it yet. The caller is expected to update the user, which will save the event.
      def build_from_request(user, category, request)
        ip_addr = request.remote_ip
        IpGeolocation.create_or_update!(ip_addr)
        user_session = UserSession.new(session_id: request.session[:session_id], ip_addr: ip_addr, user_agent: request.user_agent)

        user.user_events.build(user: user, category: category, user_session: user_session, ip_addr: ip_addr, session_id: request.session[:session_id], user_agent: request.user_agent)
      end

      def create_from_request!(...)
        event = build_from_request(...)
        event.save!
        event
      end
    end
  end

  memoize def parsed_user_agent
    UserAgent.new(user_agent)
  end
end
