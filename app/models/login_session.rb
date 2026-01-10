# frozen_string_literal: true

# A login session is used to track a user's active logins. A login session is created when a user logs in and is
# invalidated when they log out or change their password.
#
# A login session has a login ID and a session ID. The login ID is stored in the user's session cookie and is used to
# identify their current login session. It's cleared when the user logs out. The session ID is also stored in the
# session cookie, but it isn't cleared when the user logs out, so it can be shared across multiple logins.
class LoginSession < ApplicationRecord
  attribute :id
  attribute :created_at
  attribute :updated_at
  attribute :user_id
  attribute :login_id, :md5, default: -> { SecureRandom.hex(16) }
  attribute :session_id, :md5
  attribute :status, default: :active
  attribute :last_seen_at, default: -> { Time.zone.now }

  enum :status, {
    active: 0,        # The login session is valid.
    logged_out: 1000, # The login session is invalid because the user logged out.
    revoked: 2000,    # The login session is invalid because it was revoked by the system (e.g. by a password change).
    expired: 3000,    # The login session is invalid because it was expired for inactivity by the system.
  }

  scope :inactive, -> { where.not(status: :active) }

  belongs_to :user
  has_many :user_events, primary_key: :login_id, inverse_of: :login_session, dependent: :destroy

  def revoke!
    update!(status: :revoked)
  end

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(user: user)
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, %i[id created_at updated_at user login_id session_id status last_seen_at], current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:user]
  end
end
