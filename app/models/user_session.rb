# A UserSession contains browser and IP metadata associated with a UserEvent. This
# includes the user's session ID from their session cookie, their IP address,
# and their browser user agent. This is used to track logins and other events.

class UserSession < ApplicationRecord
  attribute :ip_addr, :ip_address

  belongs_to :ip_geolocation, foreign_key: :ip_addr, primary_key: :ip_addr, optional: true

  def self.visible(user)
    if user.is_moderator?
      all
    else
      none
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :session_id, :user_agent, :ip_addr, :ip_geolocation)
    q = q.apply_default_order(params)
    q
  end
end
