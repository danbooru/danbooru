# frozen_string_literal: true

# A UserEvent is used to track important events related to a user's account, such as signups, logins, password changes, etc.
# An event tracks the user's IP address, session ID, and user agent at the time of the event.

class UserEvent < ApplicationRecord
  extend Memoist

  self.ignored_columns += [:user_session_id]

  # Events that were performed by the user while logged in, for tracking the user's authorized IP addresses. This does not
  # include failed login attempts, password reset requests, or other events that may not have been performed by the user.
  AUTHORIZED_EVENTS = %i[
    login login_verification reauthenticate logout user_creation user_deletion user_undeletion
    password_reset password_change email_change totp_enable totp_update totp_disable
    totp_login totp_reauthenticate backup_code_generate backup_code_login backup_code_reauthenticate
    api_key_create api_key_update api_key_delete
  ]

  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :user_id
  attribute :category
  attribute :ip_addr, :ip_address
  attribute :login_session_id, :md5
  attribute :session_id, :md5
  attribute :user_agent
  attribute :metadata

  belongs_to :user
  belongs_to :ip_geolocation, foreign_key: :ip_addr, primary_key: :ip_addr, optional: true
  belongs_to :login_session, primary_key: :login_id, inverse_of: :user_events, optional: true

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
    api_key_create: 900,                  # The user created a new API key.
    api_key_update: 910,                  # The user changed the permissions of an API key.
    api_key_delete: 920,                  # The user deleted an API key.
  }

  normalizes :user_agent, with: ->(user_agent) { user_agent.to_s.truncate(800, separator: " ", omission: " ...") }

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

  concerning :SockpuppetMethods do
    class_methods do
      # @return [ActiveRecord::Relation<UserEvent>] A list of user events that share a session ID with the given user.
      def shared_session_ids_for(user)
        authorized
          .where.not(user_id: user.id)
          .where(session_id: authorized.where(user: user).select(:session_id))
          .group([:session_id, :user_id])
          .select(:session_id, :user_id)
      end

      # @return [ActiveRecord::Relation<UserEvent>] A list of user events that share an IP /24 or /64 subnet with the given user.
      def shared_ip_addresses_for(user)
        subnet = "network(set_masklen(user_events.ip_addr, CASE WHEN family(user_events.ip_addr) = 4 THEN 24 ELSE 64 END))"

        authorized
          .where.not(user_id: user.id)
          .where("#{subnet} IN (?)", authorized.where(user: user).joins(:ip_geolocation).where(ip_geolocation: { is_proxy: false }).select(subnet))
          .group([subnet, :ip_addr, :user_id])
          .select(Arel.sql("#{subnet} AS subnet, ip_addr, user_id"))
      end
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :category, :user, :ip_addr, :session_id, :user_agent, :metadata, :ip_geolocation], current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:user]
  end

  concerning :ConstructorMethods do
    class_methods do
      # @param user [User] The user who performed the event, or the user whose account was affected by the event.
      # @param category [Symbol] The event category, e.g. :login, :logout, :user_creation, etc.
      # @param request [ActionDispatch::Request] The HTTP request that triggered the event.
      # @param login_session [LoginSession, nil] The login session associated with the event. If not provided, it will be taken from the `login_id` session cookie.
      def create_from_request!(user, category, request, login_session: nil)
        login_session_id = login_session&.login_id || request.session[:login_id]
        ip_addr = request.remote_ip
        IpGeolocation.create_or_update!(ip_addr)

        create!(user: user, category: category, ip_addr: ip_addr, login_session_id: login_session_id, session_id: request.session[:session_id], user_agent: request.user_agent)
      end
    end
  end

  memoize def parsed_user_agent
    Danbooru::UserAgent.new(user_agent)
  end
end
