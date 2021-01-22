# A UserEvent is used to track important events related to a user's account,
# such as signups, logins, password changes, etc. A UserEvent is associated
# with a UserSession, which contains the IP and browser information associated
# with the event.

class UserEvent < ApplicationRecord
  belongs_to :user
  belongs_to :user_session

  enum category: {
    login: 0,
    failed_login: 50,
    logout: 100,
    user_creation: 200,
    user_deletion: 300,
    password_reset: 400,
    password_change: 500,
    email_change: 600,
  }

  delegate :session_id, :ip_addr, :ip_geolocation, to: :user_session
  delegate :country, :city, :is_proxy?, to: :ip_geolocation, allow_nil: true

  def self.visible(user)
    if user.is_admin?
      all
    elsif user.is_moderator?
      where(category: [:login, :logout, :user_creation]).or(where(user: user))
    else
      where(user: user)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :category, :user, :user_session)
    q = q.apply_default_order(params)
    q
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

        user.user_events.build(user: user, category: category, user_session: user_session)
      end

      def create_from_request!(...)
        build_from_request(...).save!
      end
    end
  end
end
